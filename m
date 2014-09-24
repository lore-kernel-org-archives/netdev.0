From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Fw: [Bug 84951] New: 8021q: kernel doesn't take into account
 ethernet header bytes for received packets
Date: Wed, 24 Sep 2014 10:36:49 -0400
Message-ID: <5422D701.7080505@gmail.com>
References: <20140922090134.3a114531@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:63827 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbaIXOgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 10:36:52 -0400
Received: by mail-qg0-f47.google.com with SMTP id z107so6029718qgd.34
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 07:36:51 -0700 (PDT)
In-Reply-To: <20140922090134.3a114531@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2014 12:01 PM, Stephen Hemminger wrote:
> I am inclined to think this is something that is just an incorrect
> user expectation.

Looks like a valid bug.  vlan just uses skb->len which already had
the eth header stripped off, so it will always under-report 12 bytes
per packet.

-vlad

> 
> Begin forwarded message:
> 
> Date: Sun, 21 Sep 2014 11:47:22 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 84951] New: 8021q: kernel doesn't take into account ethernet header bytes for received packets
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=84951
> 
>             Bug ID: 84951
>            Summary: 8021q: kernel doesn't take into account ethernet
>                     header bytes for received packets
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.16.1
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: g.djavadyan@gmail.com
>         Regression: No
> 
> Statistics exported by the kernel for received packets on 802.1q subinterfaces
> don't consider Ethernet header bytes (dst MAC, src MAC, type). Statistics for
> transmitted packets is not affected. The problem is more prominent on
> high-speed links (>100Mb/s), as networking tools (nload, iftop, ...) display
> lower bandwidth utilization (>5Mb/s difference) than a report from neighboring
> routing device (FreeBSD, Cisco). Also, someone monitoring Linux router
> interfaces will find that the router generates more information than it
> receives.
> 
> Tested on CentOS kernel 2.6.32-431.29.2.el6.x86_64 and vanilla 3.16.1 with
> drivers: bnx2, atl1c and igb.
> 
> How to reproduce:
> 
> 1. Create dot1q subinterfaces on two boxes (vconfig add eth0 4040).
> 2. Assign IP addresses to subinterfaces.
> 3. Check the connection using ping.
> 4. Check the output from ifconfig eth0.4040 or 'cat
> /sys/class/net/eth0.4040/statistics/rx_{packets,bytes}'.
> 5. Issue standard 56 byte payload ping using 'ping -c 1 neighboring_ip'.
> 6. Recheck statistics using step 4.
> 
> Expected results:
> 
> Received packets value should increase by 1 and received bytes value should
> increase by 98.
> 
> dst MAC - 6
> src MAC - 6
> ethertype - 2
> IP header - 20
> ICMP header - 8
> ICMP Payload - 56
> Total: 98 bytes.
> 
> 
> Actual results:
> 
> Received packets value increases by 1 and received bytes value increases by 84
> bytes.
> 
