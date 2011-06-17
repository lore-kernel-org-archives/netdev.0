From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [AX25] inconsistent lock state
Date: Fri, 17 Jun 2011 16:11:10 +0200
Message-ID: <201106171611.10655.arnd@arndb.de>
References: <4B2CD772.1030106@upmc.fr> <201106171536.15660.arnd@arndb.de> <20110617135147.GA3470@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: f6bvp <f6bvp@free.fr>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110617135147.GA3470@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 June 2011 15:51:48 Ralf Baechle wrote:
> On Fri, Jun 17, 2011 at 03:36:15PM +0200, Arnd Bergmann wrote:
> 
> (Removed Jarek from cc; his email bounces.)
> 
> > The message hints that disc_data_lock is aquired with softirqs disabled,
> > but does not itself disable softirqs, which can in rare circumstances
> > lead to a deadlock.
> > 
> > Does this fix it?
> 
> If so, drivers/net/hamradio.c, function sp_get() would probably need the
> equivalent fix.  Same for drivers/net/ppp_async.c:ap_get() and sp_get() in
> drivers/net/ppp_synctty.c.

It seems that ppp_synctty.c is ok, it uses write_lock_irq() already,
sixpack.c looks like it has the same bug as mkiss. I also realized
after sending out the patch that only the write_lock needs to be
changed to write_lock_bh, while read_lock can leave softirqs enabled
because it can be called recursively.

	Arnd
