From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFT][PATCH] cleanup net/atm/br2684.c
Date: Tue, 12 Aug 2003 12:44:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308121644.h7CGiVsG001282@ginger.cmf.nrl.navy.mil>
References: <20030811114823.5b81474c.shemminger@osdl.org>
Reply-To: chas3@users.sourceforge.net
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-reply-to: Your message of "Mon, 11 Aug 2003 11:48:23 PDT."
             <20030811114823.5b81474c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>	- Get rid of all the MOD_INC stuff. MOD_INC is not a spinlock or semaph
>ore
>	  and don't use it like that!  Have driver clean itself up properly on
>	  unload.

i actually have a patch for that already.  pppoatm has the same problem.
since both are now holding semaphores during ioctl most of the MOD_* stuff
can go away.  however, one pair needs to kept around in br2684 to keep the
module from being removed while the user space process is keeping the
vcc's in place.  this will go away when everything is converted to netlink.

>+	netdev = alloc_netdev(sizeof(struct br2684_dev),
>+			      ni.ifname[0] ? ni.ifname : "nas%d",
>+			      br2684_setup);
>+	if (!netdev)
>+		return -ENOMEM;
>...
>+
>+	write_lock_irq(&devs_lock);
>+	brdev->number = list_empty(&br2684_devs) ? 1 :
>+	    list_entry_brdev(br2684_devs.prev)->number + 1;
>+	list_add_tail(&brdev->br2684_devs, &br2684_devs);
>+	write_unlock_irq(&devs_lock);
> 	return 0;

this is a little different than the old code.  if the user didnt
provide an ifname, then brdev->number is used to determine the
name of the interface instead of letting the network stack choose
the next available interface name.  not sure if this really matters
to anyone.
