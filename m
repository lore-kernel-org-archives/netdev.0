From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: set default DEVTYPE for all ethernet based devices
Date: Thu, 30 Jan 2014 16:28:41 -0800 (PST)
Message-ID: <20140130.162841.525938031146003411.davem@davemloft.net>
References: <1391088002-15650-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stephen@networkplumber.org, avi.kp.137@gmail.com,
	mchehab@redhat.com, horms@verge.net.au, marcel@holtmann.org,
	gregkh@linuxfoundation.org, kay@vrfy.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391088002-15650-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Thu, 30 Jan 2014 14:20:02 +0100

> In systemd's networkd and udevd, we would like to give the administrator a
> simple way to filter net devices by their DEVTYPE [0][1]. Other software
> such as ConnMan and NetworkManager uses a similar filtering already.
> 
> Currently, plain ethernet devices have DEVTYPE=(null). This patch sets the
> devtype to "ethernet" instead. This avoids the need for special-casing the
> DEVTYPE=(null) case in userspace, and also avoids false positives, as there
> are several other types of netdevs that also have DEVTYPE=(null).
> 
> Notice that this is done, as suggested by Marcel, in alloc_etherdev_mqs(),
> and as best I can tell it will not give any false positives. I considered
> doing it in ether_setup() instead as that seemed more intuitive, but that
> would give a lot of false positives indeed.
> 
> [0]: <http://www.freedesktop.org/software/systemd/man/systemd-networkd.service.html#Type>
> [1]: <http://www.freedesktop.org/software/systemd/man/udev.html#Type>
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>

Assuming that all users of alloc_etherdev*() are ethernet devices is
really not going to work.
