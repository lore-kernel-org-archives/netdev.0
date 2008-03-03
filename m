From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 2/4 net-2.6.26] [IPV4]: Cleanup ip_options_compile.
Date: Mon, 03 Mar 2008 23:54:58 +0300
Message-ID: <1204577698.23504.13.camel@iris.sw.ru>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
	 <1204559323-19953-2-git-send-email-den@openvz.org>
	 <20080303.115509.71743609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21367 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbYCCUzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:55:07 -0500
In-Reply-To: <20080303.115509.71743609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-03-03 at 11:55 -0800, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Mon,  3 Mar 2008 18:48:41 +0300
> 
> > Right now ip_options_compile is called twice as (NULL, skb) and (opt, NULL).
> > So, let's move opt initialization into caller and remove this initialization
> > branch.
> > 
> > Additionally, the field ip_options->is_data becomes not needed. All decisions
> > should be made by the real skb availability.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> I don't think this "is_data" elimination works.
> 
> Sometimes these option blobs come from the user or elsewhere.  And
> that's why we have to sometimes use opt->__data instead of the SKB
> embedded blob.
> 
> You also missed the is_data case in cipso_ipv4.c, so this wouldn't
> even compile.  Is there something wrong with "git grep" on your
> computer?

thanks for pointing this out.

Though, it seems to me, that this structure does not came from
userspace. At least I do not see a way for this. Could you show me how
this can happen?

