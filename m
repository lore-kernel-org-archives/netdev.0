From: David Stevens <dlstevens@us.ibm.com>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 12:40:56 -0700
Message-ID: <OF41E6EC02.7524B9F0-ON88257376.006B78BD-88257376.006C0648@us.ibm.com>
References: <002601c81025$ee0af8f0$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "'Netdev'" <netdev@vger.kernel.org>
To: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60303 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbXJPTlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:41:05 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9GIW8TG002718
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 14:32:08 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9GJexr3475736
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 13:40:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9GJewgl007849
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 13:40:59 -0600
In-Reply-To: <002601c81025$ee0af8f0$04ac10ac@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> hmm maybe I misunderstand here, but the we are trying to make OSPF work
> in 2.6 and the problem appears to be that our board does not pick up
> multicasts.
> Is icmp_echo_ignore_broadcasts=0 required to make OSPF work in 2.6?
> 
>  Jocke
> 

        No, it's required to make "ping" to a multicast address
work, which is what your mail said was the problem. :-) "ping"
uses ICMP, OSPF does not.
        If you receive ping responses with ignore_broadcasts=0
and not in promiscuous mode, then the problem may be a smart
switch that doesn't understand IGMPv3. In that case, you
can try:

sysctl -w net.ipv4.conf.all.force_igmp_version=2

        You can also, of course, check /proc/net/igmp and
/proc/net/dev_mcast to make sure you've joined the OSPF
multicast address on the interface(s) you care about.

                                                +-DLS

