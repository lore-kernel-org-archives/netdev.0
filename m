From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix cached ct with helper.
Date: Tue, 10 May 2016 17:31:30 -0700
Message-ID: <CAPWQB7H9CxqgwE_K6_7-PgeoeV2FR=0T8=JXEhVbkpR-WKTk4g@mail.gmail.com>
References: <1462905631-12209-1-git-send-email-joe@ovn.org> <67865008-7CDC-469D-8EAA-C097C19F7408@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:33749 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbcEKAbz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 20:31:55 -0400
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id 87B9F172097
	for <netdev@vger.kernel.org>; Wed, 11 May 2016 02:31:52 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id u2fiVHWyHv6u for <netdev@vger.kernel.org>;
	Wed, 11 May 2016 02:31:51 +0200 (CEST)
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	(Authenticated sender: joe@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id F103D17209B
	for <netdev@vger.kernel.org>; Wed, 11 May 2016 02:31:50 +0200 (CEST)
Received: by mail-oi0-f47.google.com with SMTP id v145so43144018oie.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 17:31:50 -0700 (PDT)
In-Reply-To: <67865008-7CDC-469D-8EAA-C097C19F7408@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 May 2016 at 16:55, Jarno Rajahalme <jarno@ovn.org> wrote:
> This would result in inconsistent helper assignment if a first CT action assigns a helper and a further CT action tries to assign a different helper; Typically the second helper assignment would be ignored, but if the unconfirmed conntrack entry is lost due to an upcall the second helper assignment would be successful.  This is best resolved by allowing helper assignment by a committing CT action only by testing the 'info->commit' flag in addition to the conditions you have there already. It may also be helpful to fail helper assignment without the commit flag in parse_ct().

Strictly speaking I think that skb_nfct_cached() handles at least some
of those cases but I agree it should be more explicit here. I'll send
a v2. We can follow up separately on net-next to improve the
parsing/make that more user-friendly.
