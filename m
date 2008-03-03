From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-2.6.26] [IPV4]: Cleanup ip_options_compile.
Date: Mon, 03 Mar 2008 11:55:09 -0800 (PST)
Message-ID: <20080303.115509.71743609.davem@davemloft.net>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
	<1204559323-19953-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750776AbYCCTzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:55:24 -0500
In-Reply-To: <1204559323-19953-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon,  3 Mar 2008 18:48:41 +0300

> Right now ip_options_compile is called twice as (NULL, skb) and (opt, NULL).
> So, let's move opt initialization into caller and remove this initialization
> branch.
> 
> Additionally, the field ip_options->is_data becomes not needed. All decisions
> should be made by the real skb availability.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

I don't think this "is_data" elimination works.

Sometimes these option blobs come from the user or elsewhere.  And
that's why we have to sometimes use opt->__data instead of the SKB
embedded blob.

You also missed the is_data case in cipso_ipv4.c, so this wouldn't
even compile.  Is there something wrong with "git grep" on your
computer?
