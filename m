From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: SFQ: backport some features from ESFQ (try 5)
Date: Mon, 29 Oct 2007 00:22:59 -0700
Message-ID: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50301 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbXJ2HXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 2222317C2CF
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:23:09 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IM7sUd-AGv5S for <netdev@vger.kernel.org>;
	Mon, 29 Oct 2007 02:23:09 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id AAC3217C094
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:23:08 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Patchset try 2 addresses the review by Michael Buesch.
Patchset try 3 addresses the review by Patrick McHardy.
Patchset try 4 has a few cosmetic improvements.
Patchset try 5 addresses further review by Patrick McHardy.

This set of patches is substantially the same as my previous try, with
changes made according to Patrick's recommendations.

Iproute2 patches will follow shortly.



The following is the original patch text.

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

Thanks for your consideration,
Corey


 include/linux/pkt_sched.h |   23 ++-
 net/sched/sch_sfq.c       |  434 +++++++++++++++++++++++++++++++--------------
 2 files changed, 319 insertions(+), 138 deletions(-)


[PATCH 1/8] Preparatory refactoring part 1.
[PATCH 2/8] Preparatory refactoring part 2.
[PATCH 3/8] Make "depth" (number of queues) user-configurable
[PATCH 4/8] Add divisor.
[PATCH 5/8] Make qdisc changeable.
[PATCH 6/8] Remove comments about hardcoded values.
[PATCH 7/8] Rework perturb_period.
[PATCH 8/8] Use nested compat attributes to pass parameters.
