From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: SFQ: backport some features from ESFQ (try 2)
Date: Sun, 29 Jul 2007 17:21:09 -0700
Message-ID: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37092 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903AbXG3AVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 1BDCC17C316
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 19:21:23 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id JQx5IA6xba-u for <netdev@vger.kernel.org>;
	Sun, 29 Jul 2007 19:21:22 -0500 (CDT)
Received: from bugfood (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 5D0FB17C212
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 19:21:20 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Patchset try 2 addresses the review by Michael Buesch.

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
 net/sched/sch_sfq.c       |  296 ++++++++++++++++++++++++++++-----------------
 2 files changed, 187 insertions(+), 117 deletions(-)

[PATCH 1/7] Preparatory refactoring part 1.
[PATCH 2/7] Preparatory refactoring part 2.
[PATCH 3/7] Move two functions.
[PATCH 4/7] Add "depth".
[PATCH 5/7] Add divisor.
[PATCH 6/7] Make qdisc changeable.
[PATCH 7/7] Remove comments about hardcoded values.
[PATCH] [iproute2] SFQ: Support changing depth and divisor.
