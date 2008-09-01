From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11470] New: pppoe not working when acting as
 gateway.
Date: Mon, 01 Sep 2008 14:04:31 +0200
Message-ID: <48BBDA4F.2090601@trash.net>
References: <bug-11470-10286@http.bugzilla.kernel.org/> <20080831111718.d47fa76f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	pigi@frumar.it
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756631AbYIAMEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 08:04:34 -0400
In-Reply-To: <20080831111718.d47fa76f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sun, 31 Aug 2008 09:59:12 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11470
>>
>>            Summary: pppoe not working when acting as gateway.
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.26.3
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Netfilter/Iptables
>>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>>         ReportedBy: pigi@frumar.it
>>                 CC: networking_netfilter-iptables@kernel-bugs.osdl.org
>>
>>
>> Latest working kernel version: 2.6.21.7
>> Earliest failing kernel version: 2.6.22
>> Distribution: Slackware 
>> Hardware Environment:  Ibm Thinkpad T23  Intel(R) Pentium(R) III Mobile CPU    
>>  1133MHz
>> Software Environment:
>> Problem Description:
>> Packet are not handled back to clients, neither are see on ppp0
>>
>> Steps to reproduce: 
>> Just put a MASQUERADE rule in iptables, to NAT packects from client to
>> internet, with a FORWARD rule that allow the packects to be forwarded. Try to
>> ping or dig or telnet or whatever from the client and nothing happens.
>>
>> My configuration is :
>>
>> CLIENT ----> T23 -----> DSL-MODEM -----> INTERNET
>>
>>
>> Client = linux machine 
>> T23 = linux machine with everything configure to act as a dsl router 
>> On T23 I'm using vanilla kernel recompiled by myself, using the same config
>> that is working on 2.6.21.7
>> pppoe binaries is :
>> root /usr/src >/usr/sbin/pppoe -V
>> Roaring Penguin PPPoE Version 3.8
>>
>>
>> I have another linux machine on internet, that I have used to verify the
>> problem.
>>
>> When I run the ping from the client, on the router I can see the packet come in
>> from the eth0 and leaving natted from the ppp0. On the internet machine I see
>> the icmp packet ( or whatever packet I send ) coming in, and the reply going
>> out  to the router machine.
>> This packet seems to be lost ( i can't see it on the router either on ppp
>> interface than on eth0 interface ), by using tcpdump (3.9.5).
>> If the communication is started from the router ( icmp, ssh, whatever )
>> everything works well.
>>
>> Running the 2.6.21.7 but keeping the same configuration for kernel, iptables
>> and all, is seen on router and handled back to client.
>> Not working behavior is seen on 2.6.22+ to 2.6.26.3
>> Working behavior is seen on 2.6.21.7- ( at last to 2.6.19.2 which was my
>> starting kernel ) 
>>
>> At beginning I thought the problem was with iptables
>> root /usr/src >iptables -V
>> iptables v1.3.8
>> but the strange thing is that I can't even see the reply packets on ppp0
>> interface, while if the trouble was on iptables rules, then I should have seen
>> the packet and then I should have seen it dropped somewhere.
>> Anyway I have put netfilters guys in CC just in case I'm wrong.
>>
>> Googling around I have seen others that have similar behavior and I have seen
>> that in 2.6.22 there is been a lot of change in pppoe area.

2.6.22 is the first kernel where we removed IPv4 only conntrack.
My guess is that some of the necessary modules aren't loaded,
we were missing a dependency or two in the beginning. Specifically,
IIRC the NAT module didn't pull in nf_conntrack_ipv4, so please
make sure that module is loaded. In case it is, please post
the full list of loaded modules.
