From: Ed Tomlinson <edt@aei.ca>
Subject: Re: 2.6.30-rc1 A few issues and a stall
Date: Tue, 14 Apr 2009 18:03:14 -0400
Message-ID: <200904141803.14660.edt@aei.ca>
References: <200904121124.07193.edt@aei.ca> <200904140832.25057.edt@aei.ca> <49E4840E.6010300@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail001.aei.ca ([206.123.6.130]:49983 "EHLO mail001.aei.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233AbZDNWDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 18:03:18 -0400
In-Reply-To: <49E4840E.6010300@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 April 2009 08:39:42 Avi Kivity wrote:
> Ed Tomlinson wrote:
> > On Tuesday 14 April 2009 06:03:58 Avi Kivity wrote:
> >   
> >> Ed Tomlinson wrote:
> >>     
> >>> Once the above networking stuff is setup I start kvm with the command below
> >>>
> >>> QEMU_AUDIO_DRV=alsa kvm -m 1024 -cdrom /mnt/sdc4/divx/archlinux-2009.02-ftp-i686.iso -boot c -smp 3 -usb -usbdevice tablet -vga std -drive file=arch.img -net nic,macaddr=52:54:00:12:34:23 -net tap,ifname=qtap0,script=no -soundhw all -mem-path /hugepages
> >>>
> >>> which works and the kvm session boots just fine.  
> >>>
> >>> Issue 2.  When I attempt to ping outside the kvm session the pc (not just the kvm session) hangs.
> >>> Its impossible to kill the kvm session and there are numerious info messages from RCU (tree RCU enabled)
> >>> about stalls.  
> >>>   
> >>>       
> >> The rcu messages are likely because a processor has died.
> >>
> >> Do things work if you drop -mem-path?
> >>     
> >
> > It makes no difference.  I did notice that one cpu is peged at 100% though.  I'll be trying
> > CONFIG_PROVE_LOCKING tonight for another problem - might give interesting results.
> >   
> 
> Oh, so this goes away without CONFIG_PROVE_LOCKING?

Nothing goes away.  This happens without CONFIG_PROVE_LOCKING active in the kernel.  Given 
that one CPU is running at 100% I suspect that a spinlock is stuck...

Ed
