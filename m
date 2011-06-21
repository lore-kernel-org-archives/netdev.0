From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 14:30:04 -0400
Message-ID: <20110621183004.GE16311@hmsreliant.think-freely.org>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
 <20110621100858.70c23a93@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60374 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab1FUSaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:30:13 -0400
Content-Disposition: inline
In-Reply-To: <20110621100858.70c23a93@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2011 at 10:08:58AM -0700, Stephen Hemminger wrote:
> On Tue, 21 Jun 2011 09:00:40 -0400
> Prarit Bhargava <prarit@redhat.com> wrote:
> 
> > Add Network Sysrq Support
> > 
> > In some circumstances, a system can hang/lockup in such a way that the system
> > is completely unresponsive to keyboard or console input but is still
> > responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> > net/ipv4/sysrq-ping.ko which allows a root user to configure the system for
> > a remote sysrq.
> > 
> > To use this do:
> > 
> > mount -t debugfs none /sys/kernel/debug/
> > echo 1 > /proc/sys/kernel/sysrq
> > echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
> > echo 1 > /sys/kernel/debug/network_sysrq_enable
> > 
> > Then on another system on the network you can do:
> > 
> > ping -c 1 -p <up to 30 hex digit val><hex val of sysrq> <target_system_name>
> > 
> > ex) sysrq-m, m is ascii 0x6d
> > 
> > ping -c 1 p 1623a06f554d46d676d <target_system_name>
> > 
> > Note that the network sysrq automatically disables after the receipt of
> > the ping, ie) it is single-shot mode.  If you want to use this again, you
> > must complete the above four steps again.
> > 
> > Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> 
> Isn't same functionality already available with netconsole?
Negative, netconsole is a unidirectional protocol.  It registers no rx_hook and
so it doesn't receive frames.  It could be added, and we could add this
functionality that way, but that would seem wierd (to me at least):

1) It would mean that netconsole was writeable, which means we would need a
utility on the remote server to do that writing to the proper udp port

2) Said utility in (1) would have some security concerns, unless we implemented
the exact same magic key sequencing that prarit has here.  Otherwise any
attacker could send an unsolicited request to the netconsole port on a system.
I like the idea of keeping this functionality separate from a feature that gets
such wide use in a production environment.

I've hacked this kind of feature together to solve this problem a few times now,
I think it would be good to have it as a well defined feature permanently.
Acked-by: Neil Horman <nhorman@tuxdriver.com> 

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
