From: Paul Moore <paul.moore@hp.com>
Subject: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 16:31:34 -0400
Message-ID: <200708221631.34234.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas04.tay.hp.com ([161.114.80.247]:50837 "EHLO
	tayrelbas04.tay.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933333AbXHVUyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:54:24 -0400
Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by tayrelbas04.tay.hp.com (Postfix) with ESMTP id AD07F35E2E
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 16:31:42 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 595431B2261
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 20:31:37 +0000 (UTC)
Received: from localhost (ldl.fc.hp.com [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 3667739C199
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 14:31:37 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl.fc.hp.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TlGmPDHEcWJV for <netdev@vger.kernel.org>;
	Wed, 22 Aug 2007 14:31:35 -0600 (MDT)
Received: from flek.americas.hpqcorp.net (flek.americas.hpqcorp.net [16.116.100.36])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by ldl.fc.hp.com (Postfix) with ESMTP id 8CF2F134A9D
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 14:31:35 -0600 (MDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Over in LSM/SELinux land there has been a lot of talk recently about how to 
deal with loopback and forwarded traffic, specifically, how to preserve the 
sender's security label on those two types of traffic.  Yes, there is the 
existing sk_buff.secmark field but that is already being used for something 
else and utilizing it for this purpose has it's pros/cons.

We're currently talking about several different ideas to solve the problem, 
including leveraging the sk_buff.secmark field, and one of the ideas was to 
add an additional field to the sk_buff structure.  Knowing how well that idea 
would go over (lead balloon is probably an understatement at best) I started 
looking at what I might be able to remove from the sk_buff struct to make 
room for a new field (the new field would be a u32).  Looking at the sk_buff 
structure it appears that the sk_buff.dev and sk_buff.iif fields are a bit 
redundant and removing the sk_buff.dev field could free 32/64 bits depending 
on the platform.  Is there any reason (performance?) for keeping the 
sk_buff.dev field around?  Would the community be open to patches which 
removed it and transition users over to the sk_buff.iif field?  Finally, 
assuming the sk_buff.dev field was removed, would the community be open to 
adding a new LSM/SELinux related u32 field to the sk_buff struct?

Thanks.
 
-- 
paul moore
linux security @ hp
