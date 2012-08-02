From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Thu, 02 Aug 2012 15:55:23 -0700
Message-ID: <87ipd0ykdg.fsf@xmission.com>
References: <5017E786.5000102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <5017E786.5000102@free.fr> (Bernard Pidoux's message of "Tue, 31
	Jul 2012 16:11:18 +0200")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernard Pidoux <bernard.pidoux@free.fr> writes:

> Hi,
>
> I observe systematically a kernel panic when I try to shutdown rose0 device
> using ifconfig rose0 down
>
> This is happening on two very different ROSE implementation, one is on a machine
> with x86-64 kernel 4.6.3 on an Intel core 2 duo CPU
> the other is on a RaspBerry Pi with Raspbian and 3.1.9+ wheezy kernel
> recompiled with AX.25 modules (ax25, rose, netrom, 6pack, kiss) enabled.
>
> Here is an image of the screen dump :
>
> http://f6bvp.org/photos/rose_device_event.JPG

For some reason I can not connect f6bvp.org.

> It can be noticed that PC is at rose_device_event and
> LR is at sock_def_wakeup
>
> One thing to be noticed is that when I close before all ROSE and AX.25
> applications, there are still a few populated sockets, probably for one of the
> program did not close the sockets properly.
>
> I that case, does rose module should accept to shutdown rose0 device ?
> However, I guess that it should not create a kernel panic due to a kernel NULL
> pointer.

No.  The kernel should not panic.

> I don't know what to do in order to debug that issue.

I assume that rose is interesting to you and you would like for it to
work better?

In general you can read the code and figure out what it is doing ref
counting wise.  It doesn't look like anyone has done much with the rose
code for years except very basic maintenance across the kernel.  It
scares me to know that I was the last one to touch the rose code.

Part of what is happening at the time of the panic is
unregister_netdevice_notifier now generates synthetic removal for all of
the network devices in the system to remove the need for a special path
to handle network device removal in modules.

Unfortunately it looks like one of those modules is a problem.

You might want to simply try moving unregister_netdevice_notifier a bit
earlier in rose_exit and see if that helps.  Otherwise I would recommend
instrumenting the code up with some printk so you can understand what
part of unregistration is failing.

Eric
