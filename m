From: Luuk Paulussen <luuk.paulussen@alliedtelesis.co.nz>
Subject: Add tcindex to conntrack and add netfilter target/matches
Date: Wed, 16 Dec 2015 13:20:35 +1300
Message-ID: <1450225236-10052-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
Cc: kyeong.yoo@alliedtelesis.co.nz, matt.bennett@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:56137 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbbLPAU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 19:20:56 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 7CEF180716
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:20:45 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I recently posted this patch to the netfilter-devel and lartc mailing lists.  The
feedback I have had so far has mostly been questions around how we would use this, and some
suggestions that don't solve the issues.  I haven't had any negative feedback.

The key use case is to mark first packet in flows in either direction using all xtables rules
and then save the mark into the connection.  For subsequent packets in the flow, restore mark
and skip full processing.  Flows that don't match any rule are still marked with a default mark
so that future packets in the flow don't have to go through all of the rules.

Comments/suggestions so far:
 - Use/extend cls_flow to handle tc_index from connection directly. - cls_flow can't
   be used with class-based qdiscs, and also being able to restore with a mask is
   useful for separating request/response from flow.  Also tcindex filter already exists. (This
   suggestion implies that tc_index will be added to the connection information)
 - use CLASSIFY target in xtables and use cls_flow to match prioirity. - CLASSIFY doesn't allow
   the desired performance benefits of restoring mark from connection and we can't use cls_flow.
 - cls_bfp supports tc_index. - I think that this is an argument for having more ways to set it.

The full discussion on netfilter-devel is available here:
http://www.spinics.net/lists/netfilter-devel/msg39746.html

I didn't get any responses on the lartc mailing list.

I would like to know if there is a possibility for this patch to be accepted into the kernel,
and/or suggestions for improvements or alternatives.
