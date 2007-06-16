From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8638] New: unregister_netdevice: waiting for
 ppp0 to become free. pppoe + multihome + htb qos?
Date: Sat, 16 Jun 2007 08:34:54 -0700
Message-ID: <20070616083454.1612ca7f.akpm@linux-foundation.org>
References: <bug-8638-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	Paul Mackerras <paulus@samba.org>, kernelbugs@tecnopolis.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35473 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757581AbXFPPfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 11:35:34 -0400
In-Reply-To: <bug-8638-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Jun 2007 03:11:30 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8638
> 
>            Summary: unregister_netdevice: waiting for ppp0 to become free.
>                     pppoe + multihome + htb qos?
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.20-1.2316.fc5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: kernelbugs@tecnopolis.ca
> 
> 
> Most recent kernel where this bug did not occur: has occurred since at least
> 2.6.18-1.2200.fc5 (Sep 2005) but could have been in earlier versions as I
> wasn't then using the tecnology I believe triggers the bug
> Distribution: FC5
> Hardware Environment: x86 P4 UP 512MB
> Software Environment: lots of cutting-edge (but stock kernel) networking
> technology
> Problem Description:
> 
> Every few months on 1 box I administer:
> kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
> system gets very locked up (but often not completely, no panics) and won't
> reboot: requires onsite hard reset.  In fact, most reboot attempts will fail
> even before the bug hits as a reboot will trigger the bug.  I always reboot the
> box with reboot -f now when I'm remote.
> 
> I have a dozen extremely similar boxes to this buggy one out there and they
> don't show this bug.  Unique to this box and I think relevant to the bug:
> 
> 1) 2 PPPoE DSL connections (multihomed, 2 IP addresses, traffic split by port,
> used to achieve higher aggregate upload bandwidth)
> 2) multi-table ip route rules ("ip rule add ... table 2") to achieve traffic
> splitting in #1.
> 
> Other technologies combined on this box but not on any others (though others
> use them separately without the bug hitting):
> 
> 3) QoS, HTB qdiscs (used on non-PPPoE boxes without the bug)
> 4) 2.6sec IPSEC VPN (used on many other PPPoE and non-PPPoE boxes without
> problems)
> 5) PPPoE (used on many other boxes without this bug)
> 
> I'm not even sure where to begin on what info to provide.  I can provide my
> config for any of the above technologies if it will help.  The box is an
> important production box and unless I can find a way to reliably make it barf
> while onsite it may be hard to test things, like "turn off QoS", because all
> the tecnologies are essential for day to day operations.
> 
> I'll attach a useful log excerpt from the last 4 times the bug hit if I can.
> 
> If this is a bad bug entry, please tell me what I need to add.  It's my first
> entry on this bugzilla and I'm not sure what's required.  I'm sorry this bug
> report is on the FC5 stock kernels, but I'm not sure I can use a "vanilla"
> kernel instead of FC5 and not screw something up.  However, there are NO binary
> modules or any weird stuff on the box.  It's all stock FC5 rpms.
> 
> This box is a production box and the only one I have with 2 PPPoE connections
> to test.  I'm nearly positive it's either a 2-PPPoE+advanced-routing problem or
> a 2-PPPoE+HTB problem.  Since I've seen no other hits on google or elsewhere
> that are exactly like this bug, I must assume it's something fairly unique to
> this box: but what combination?!
> 
> I've had a Redhat bugzilla open on this since Sep 2005 with zero replies!  It
> shows more detail and my thought process over the years.
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=169502
> 
> Steps to reproduce:
> Haven't figured out a way to reliably hit this bug.  Any hints to allow easier
> testing (which must be done onsite) are welcome.
> 

I have a vague feeling that we fixed this in a later kernel.  Does anyone
recall?

Thanks.
