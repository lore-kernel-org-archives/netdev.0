From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/11) Irda dongle module owner support
Date: Mon, 6 Oct 2003 16:23:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006232334.GA9277@bougret.hpl.hp.com>
References: <20031002152026.4bfd2c67.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031002152026.4bfd2c67.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 02, 2003 at 03:20:26PM -0700, Stephen Hemminger wrote:
> IRDA dongle interface needed to be converted to have an owner field
> to avoid races on module unload.
> 
> Eliminated the use of hashbin locking because the dongle control
> code needed to do it's own locking to avoid races.   This also closed
> the race between find and insert. 
> 
> The find/insert hashbin race may be a general problem with all the IRDA
> hashbin stuff. IMHO the hashbin stuff should be replaced, it is full
> of dead incomplete code and done better by the list macros.

	Hi,

	More testing on 2.6.0-test6-bk8 on my SMP box...
	After modprobing irport, a modprobe of the actisys module
hangs forever.

	Conditions : irport was not yet attached/up. I had irdadump
running and an irda-usb active, and I had just rmmod sir_dev.
	I can see that modprobe is taking 100% cpu :
---------------------------------------
 1786 pts/1    R      4:11 modprobe actisys
---------------------------------------
	I can't kill it !
	No messages in the log.
---------------------------------------
# cat /proc/modules 
actisys 4032 1 - Loading 0xd0859000
irport 12672 0 - Live 0xd0884000
irda 182260 5 actisys,irport,irnet,irda_usb, Live 0xd08d3000
---------------------------------------

	After a clean reboot, I just tried to modprobe actisys even
before modprobing irport. Same result :
--------------------------------
# cat /proc/modules 
actisys 4032 1 - Loading 0xd0859000
irda 182260 1 actisys, Live 0xd08d3000
--------------------------------

	Any tip for debugging that ?

	Thanks...

	Jean
