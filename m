From: Mattias =?utf-8?Q?R=C3=B6nnblom?= <hofors@lysator.liu.se>
Subject: SNMP OutOctets counter semantics
Date: Sun, 18 Apr 2010 14:16:17 +0200
Message-ID: <87bpdh7y7i.fsf@isengard.friendlyfire.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:55746 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab0DRMQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 08:16:19 -0400
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
	by mail.lysator.liu.se (Postfix) with ESMTP id 03A7340018
	for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 14:16:19 +0200 (CEST)
Received: from fritz.lysator.liu.se (fritz.lysator.liu.se [130.236.254.179])
	by mail.lysator.liu.se (Postfix) with ESMTP id 82B3140018
	for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 14:16:17 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

after having a look at the SNMP counters (exposed in /proc/net/snmp
among other places), I have a question on the meaning of the
"OutOctets" counter. I'm looking at 2.6.33.

According to include/linux/snmp.h IPSTATS_MIB_OUTPKTS is
"OutRequests". The same file refers to
"draft-ietf-ipv6-rfc2011-update-10.txt", which I believe is what
became RFC 4293. According to both of those standard documents,
"OutRequest" counts IP packets coming from upper (sub-)layers (a
transport layer, ICMP etc) into the IP layer.

This corresponds well with how this counter is actually incremented in
the code, as far as I can tell.

In 2.6.31, a corresponding byte counter "OutOctets" was introduced,
which in the Linux kernel counted the same packets as "OutRequest",
but was a byte counter.

In RFC 4293 (and its draft) there is indeed a OutOctets, but this is a
byte counter for packets _leaving_ the IP layer into the link layer.
This counter in the standard corresponds to the "OutTransmits" packet
counter, which is not implemented in the Linux kernel.

My question is: is this simply a bug, or does the kernel draw its
counter semantics from some other standard?

Best regards,
     Mattias
