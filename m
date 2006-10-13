From: Rick Jones <rick.jones2@hp.com>
Subject: getaddrinfo - should accept IPPROTO_SCTP no?
Date: Fri, 13 Oct 2006 14:30:12 -0700
Message-ID: <45300564.2050504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:18093 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S932082AbWJMVaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 17:30:14 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id B0A5936F4C
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 14:30:19 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id OAA18558
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 14:30:12 -0700 (PDT)
To: Linux Network Development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I made some recent changes to netperf to workaround what is IMO a bug in the 
Solaris getaddrinfo() where it will clear the ai_protocol field even when one 
gives it a protocol in the hints.

[If you happen to be trying to use the test-specific -D to set TCP_NODELAY in 
netperf on Solaris, you might want to grab netperf TOT to get this workaround as 
it relates to issues with setting TCP_NODELAY - modulo what it will do to being 
able to run the netperf SCTP tests on Linux...]

In the process though I have stumbled across what appears to be a bug (?) in 
"Linux" getaddrinfo() - returning a -7 EAI_SOCKTYPE if given as hints 
SOCK_STREAM and IPPROTO_SCTP - this on a system that ostensibly supports SCTP. 
I've seen this on RHAS4U4 as well as another less well known distro.

I'm about to see about concocting an additional workaround in netperf for this, 
but thought I'd ask if my assumption - that getaddrinfo() returning -7 when 
given IPPROTO_SCTP - is indeed a bug in getaddrinfo().  Or am I just woefully 
behind in patches or completely offbase on what is correct behaviour for 
getaddrinfo and hints?

FWIW, which may not be much, Solaris 10 06/06 seems content to accept 
IPPROTO_SCTP in the hints.

thanks,

rick jones
http://www.netperf.org/svn/netperf2/trunk/
