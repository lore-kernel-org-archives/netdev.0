From: Karsten Keil <kkeil@suse.de>
Subject: Why does a connect to IPv6 LLA address fail ?
Date: Wed, 7 Nov 2007 10:40:07 +0100
Message-ID: <20071107094007.GA15575@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42041 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041AbXKGJkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 04:40:09 -0500
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 894871A820
	for <netdev@vger.kernel.org>; Wed,  7 Nov 2007 10:40:08 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

currently I do some cerification test for IPv6 with the TAHI ct testsuite.
With the default-addr-select tests for compliance with RFC3484 here are
FAILs with Destination Address Selection Check Rule 2(Prefer matching
scope). Yes I know that Destination Address Selection is done in glibc,
but it seems that the kernel behaves wrong in the connect system call
with IPv6 link local addresses. 

The glibc getaddrinfo function try to verify if a address is valid and
examine the source address. For this it create a socket for datagram and
protocol IPPROTO_IP and then try to connect it with the destination
address. This fails in the case of a LLA, because connect returns EINVAL,
since here is no device bind to this socket at this time. So getaddrinfo
mark this candidate address as not reachable and so it will never prefered
because of rule 1 of RFC3484 Destination Address Selection.

Why do we have this check in ip6_datagram_connect() ?

The posix manpage for connect says about EINVAL:
"EINVAL - The address_len argument is not a valid length for the address family; or
invalid address family in the sockaddr structure."

Which is not the case here.

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
