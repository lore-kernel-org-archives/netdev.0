From: Rick Jones <rick.jones2@hp.com>
Subject: why does DCCP SO_REUSEADDR have to be SOL_DCCP?
Date: Fri, 01 Feb 2008 17:42:23 -0800
Message-ID: <47A3CA7F.8040300@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:25189 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849AbYBBBmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 20:42:25 -0500
Received: from g4t0017.houston.hp.com (localhost.localdomain [127.0.0.1])
	by receive-from-antispam-filter (Postfix) with SMTP id B398438044
	for <netdev@vger.kernel.org>; Sat,  2 Feb 2008 01:42:24 +0000 (UTC)
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id 9183838016
	for <netdev@vger.kernel.org>; Sat,  2 Feb 2008 01:42:24 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id RAA25028
	for <netdev@vger.kernel.org>; Fri, 1 Feb 2008 17:42:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

I'm tweaking the netperf omni tests to be able to run over DCCP.  I've 
run across a not-unorecedented problem with getaddrinfo() not groking 
either SOCK_DCCP or IPPROTO_DCCP in the hints, and that I can more or 
less live with - I had to do a kludge for getaddrinfo() for IPPROTO_SCTP 
under Linux at one point and I can see how the two are not necessarily 
going to be in sync.

And I've worked-around no user-level include files (ie without setting 
__KERNEL__) define the DCCP stuff, and that is OK too, albeit somewhat 
inconvenient.

My question though is why on earth does an SO_REUSEADDR setsockopt() 
against a DCCP socket have to be SOL_DCCP?  SCTP and TCP are quite happy 
with SOL_SOCKET, and it might be foolish consistency, but since the 
option _does_ begin with SO_ I'd have expected it to work for 
SOL_SOCKET, but (again RHEL5.1, yes, I do plan on getting upstream but 
have to satisfy several masters) it doesn't seem to be the case - a 
subsequent listen() or connect() call after an SOL_SOCKET SO_REUSEADDR 
against a DCCP socket leaves one SOL as it were...

Of course the setsockopt(SO_REUSEADDR) against the DCCP socket using 
SOL_SOCKET itself doesn't fail, only the later listen() or connect() call...

happy benchmarking,

rick jones
