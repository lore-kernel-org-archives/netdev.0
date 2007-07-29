From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 0/7] SFQ: backport some features from ESFQ
Date: Sun, 29 Jul 2007 00:08:47 -0700
Message-ID: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:60033 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570AbXG2HIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 03:08:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 3379217C2CE
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 02:08:53 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NYmQqrdrO0Wd for <netdev@vger.kernel.org>;
	Sun, 29 Jul 2007 02:08:53 -0500 (CDT)
Received: from bugfood (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id E6B9717C05B
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 02:08:52 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This set of patches adds some of ESFQ's modifications to the original 
SFQ. Thus far, I have received support for this approach rather than for 
trying to get ESFQ included as a separate qdisc.

http://mailman.ds9a.nl/pipermail/lartc/2007q2/021056.html

My patches here implement "tc qdisc change", user-configurable depth 
(number of flows), and user-configurable divisor (for setting hash table 
size). I've left out the remaining ESFQ features (usage of jhash and 
different hashing methods) because Patrick McHardy intends to submit a 
patch that will supersede that functionality; see the URL above.

Default values remain the same, and SFQ's default behavior remains the 
same, so there should be no user disruption.

A patch for iproute2 is included after the end of the kernel patch series.

Thanks for your consideration,
Corey


 include/linux/pkt_sched.h |    8 --
 net/sched/sch_sfq.c       |  301 +++++++++++++++++++++++++++++----------------
 2 files changed, 192 insertions(+), 117 deletions(-)

[PATCH 1/7] Preparatory refactoring part 1.
[PATCH 2/7] Preparatory refactoring part 2.
[PATCH 3/7] Move two functions.
[PATCH 4/7] Add "depth".
[PATCH 5/7] Add divisor.
[PATCH 6/7] Make qdisc changeable.
[PATCH 7/7] Remove comments about hardcoded values.
[PATCH] [iproute2] SFQ: Support changing depth and divisor.
