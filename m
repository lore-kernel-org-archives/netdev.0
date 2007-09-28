From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: SFQ: backport some features from ESFQ (try 4)
Date: Fri, 28 Sep 2007 15:52:47 -0700
Message-ID: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42842 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbXI1WxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 7CA1417C24F
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 17:53:05 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cpJrVbTEuE6G for <netdev@vger.kernel.org>;
	Fri, 28 Sep 2007 17:53:05 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 1CB3417C0D6
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 17:53:05 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Patchset try 2 addresses the review by Michael Buesch.
Patchset try 3 addresses the review by Patrick McHardy.
Patchset try 4 has a few cosmetic improvements.

Nobody reviewed my last set of patches, and I wasn't pushy about asking.
Since it's been a while, I ported the kernel and userspace patchsets to
current git of net-2.6 and iproute2, respectively.

The first 7 patches in this series resemble the corresponding 7 patches
in patchset try 2. There aren't any major changes--just modifications
to address errors noticed in review and slight reorganizations to make
the next patches easier.

Patches 8-10 implement parameter passing via nested compat attributes.
This is necessary for using 'tc qdisc change' to disable perturbation.
The rest of the parameters were added for consistency.

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



 include/linux/pkt_sched.h |   23 ++--
 net/sched/sch_sfq.c       |  353 ++++++++++++++++++++++++++++++---------------
 2 files changed, 254 insertions(+), 122 deletions(-)


[PATCH 01/10] Preparatory refactoring part 1.
[PATCH 02/10] Preparatory refactoring part 2.
[PATCH 03/10] Move two functions.
[PATCH 04/10] Make "depth" (number of queues) user-configurable:
[PATCH 05/10] Add divisor.
[PATCH 06/10] Make qdisc changeable.
[PATCH 07/10] Remove comments about hardcoded values.
[PATCH 08/10] Multiply perturb_period by HZ when used rather than when assigned.
[PATCH 09/10] Change perturb_period to unsigned.
[PATCH 10/10] Use nested compat attributes to pass parameters.
