From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: TCP TSecr question
Date: Fri, 10 Apr 2009 19:24:56 +0300
Message-ID: <49DF72D8.2020002@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28687 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S936557AbZDJQkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There is an issue with this field in SYN packets when tw reuse/recycle 
is on.
Quoting from RFC 1323, section 3.2:
    The Timestamp Echo Reply field (TSecr) is only valid if the ACK
    bit is set in the TCP header; if it is valid, it echos a times-
    tamp value that was sent by the remote TCP in the TSval field
    of a Timestamps option.  When TSecr is not valid, its value
    must be zero.  The TSecr value will generally be from the most
    recent Timestamp option that was received; however, there are
    exceptions that are explained below.

On Linux, when the sysctl_tcp_tw_reuse or recycle is on, the most recent
timestamp from a previous connection is sent instead of 0.  From what I've
seen in the source, this has to do with PAWS against delayed/duplicate SYN
packets.

My questions:
1) Is this violation of RFC 1323 useful in PAWS or did I misunderstand
   the whole situation?
2) Is there any other RFC that amends 1323 to specify this behavior or is it
   a Linux-specific enhancement?

Thank you,
Cosmin.
