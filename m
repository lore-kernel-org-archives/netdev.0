From: "Steve Hill" <steve.hill@dialogic.com>
Subject: RE: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 5 Feb 2007 12:26:14 -0500
Message-ID: <E096369D937D3A4DB271B382850C5C5F44E71C@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	<lksctp-developers@lists.sourceforge.net>,
	"Sridhar Samudrala" <sri@us.ibm.com>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from montreal.eicon.com ([192.219.17.124]:37986 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbXBERZ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:25:29 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote on 05 February 2007 17:08:

>   1. What did you set the sinfo_timetolive to?

I presume you mean the timetolive parameter of sctp_sendmsg()? - this
was set to 1400ms (as previously mentioned, this was in error but it
does appear to have highlighted a problem with the stack itself).

>   2. What specific netfilter rule to do use to simulate
> network outage?
>      I was using '-t filter -A INPUT -i eth0 -p sctp -j DROP'

iptables -A INPUT -d 192.168.2.0/24 -p sctp -j DROP

> Just trying to get more info to simulate this.  My prior attempts
> recovered quickly with my patch.

I usually (but not always - sometimes it happens on the first attempt)
have to add and remove the iptables rule a few times while running
traffic over the association in order to reproduce the problem.  I'm
running traffic at a rate of around 500 data chunks per second.  Each
data chunk has a 44 octet payload.

The script I'm using to toggle the iptables rule is below:

----------
#!/bin/sh

net="$1"

flush() {
	iptables -F
	echo "Flush"
	exit
}

trap flush EXIT

while true; do
	iptables -A INPUT -d "$net" -p sctp -j DROP
	echo "set"
	sleep 5
	iptables -F
	echo "flushed"
	sleep 5
done 
----------

 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
