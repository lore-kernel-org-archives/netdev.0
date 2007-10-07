From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net/core: split dev_ifsioc() according to locking
Date: Sun, 7 Oct 2007 02:17:08 +0200
Message-ID: <200710070217.09073.arnd@arndb.de>
References: <20071006204212.GA32177@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752647AbXJGAUn@vger.kernel.org>
In-Reply-To: <20071006204212.GA32177@havoc.gtf.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 06 October 2007, Jeff Garzik wrote:
>=20
> This always bugged me: =A0dev_ioctl() called dev_ifsioc() either insi=
de
> read_lock(dev_base_lock) or rtnl_lock(), depending on the ioctl being
> executed.
>=20
> This change moves the ioctls executed inside dev_base_lock to a new
> function, dev_ifsioc_locked(). =A0Now the locking context is complete=
ly
> clear to the reader.
>=20
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Great idea!

I've been experimenting with a new compat_dev_ioctl() function along
the lines of what I just posted for the blkdev ioctls. For that, it
would be perfect to streamline dev_ioctl further:

* move the dev_load() and locking into dev_ifsioc{,_locked}
* move the copy_to_user step to a single place at the end of dev_ioctl

After that, we could have very simple dev_ioctl and compat_dev_ioctl
functions calling the same dev_ifsioc{,_locked} functions.

	Arnd <><
