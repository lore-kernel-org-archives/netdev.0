From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH] New LSM hook to catch outbound packets
Date: Wed, 19 Dec 2007 17:20:54 -0500
Message-ID: <20071219220539.1626.46073.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:28772 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbXLSWVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 17:21:00 -0500
Received: from g1t0027.austin.hp.com (localhost.localdomain [127.0.0.1])
	by receive-from-antispam-filter (Postfix) with SMTP id 6A82538739
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 22:20:58 +0000 (UTC)
Received: from smtp2.fc.hp.com (smtp.cnd.hp.com [15.11.136.114])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 5DB473872A
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 22:20:58 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently LSMs need to use a netfilter post routing hook to catch outbound
packets and subject them to access control.  This works reasonably well but
has always been a bit awkward when IPsec or similar mechanisms were used
because the same packet would end up going through the same LSM hook multiple
times.  For obvious reasons this often resulted in unnecessary overhead and
additional headaches when trying to determining the correct LSM security
policy.

This patch attempts to fix this problem by adding a new hook into both the
IPv4 and IPv6 output path.  The motiviation behind this new hook is a request
from users to provide packet level ingress/egress access control for all
packets on the system, not just packets that are locally consumed or generated.
I know new networking LSM hooks are frowned upon but there has been a lot of
thought and discussion put into this and we haven't been able to find a better
solution.  I've trimmed the rest of the patchset from this posting as it isn't
really relevant for this discussion (the full patchset has been under
discussion on the SELinux and LSM lists), but those who are curious can find
the patches online here (this will see another update later today):

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

Thanks.

-- 
paul moore
linux security @ hp
