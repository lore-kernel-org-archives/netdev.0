From: Tony Zhang <blahhun@yahoo.com>
Subject: Design intent of IP fragment cache limit?
Date: Wed, 27 Jun 2007 13:01:12 -0700 (PDT)
Message-ID: <126403.86015.qm@web34604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web34604.mail.mud.yahoo.com ([209.191.68.138]:33507 "HELO
	web34604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752055AbXF0UHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 16:07:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am investigating an IP fragmentation flood DOS
attack scenario where the attacker sends a string of
fragmented IP packets to exhaust the victim's fragment
cache. I've checked the IP fragment reassembly
implemention on several UNIX-like OSs. NetBSD/FreeBSD
don't handle such scenario. I was hoping Linux would
upon seeing the two cache limit syctrls. But after
looking deeper into the code, I doubt it addresses
that threat either. 

So out of curiosity, I was wondering if anyone knows
the design rationale behind the high/low cache limit
for IP fragments (e.g. sysctl_ipfrag_high(low)_thresh
in ip_defrag(), ip_fragment.c). What attack scenario
does these two sysctrls address?

Thanks,
Tony

FYI:

Detailed possible attack scenario:

A BGP router is unable to detect the PMTU with its
peer (e.g. ICMP is turned off in the intermediate
router at which the MTU decreases) and thus all
packets get fragmented. If there is an attack on its
peer that exhausts its fragment buffer space, the BGP
peering cannot be established and therefore the AS
becomes completely cut off.


       
____________________________________________________________________________________Ready for the edge of your seat? 
Check out tonight's top picks on Yahoo! TV. 
http://tv.yahoo.com/
