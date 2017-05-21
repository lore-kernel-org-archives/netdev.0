From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/13] nfp: introduce very minimal nfp_app
Date: Sun, 21 May 2017 13:23:28 -0400 (EDT)
Message-ID: <20170521.132328.352349689480345479.davem@davemloft.net>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
        <20170519220155.27857-6-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kubakici@wp.pl, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEURXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:23:32 -0400
In-Reply-To: <20170519220155.27857-6-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 19 May 2017 15:01:47 -0700

> Introduce a concept of an application.  For now it's just grouping
> pointers and serving as a layer of indirection.  It will help us
> weaken the dependency on nfp_net in ethtool code.  Later series
> will flesh out support for different apps in the driver.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
 ...
> +struct nfp_cpp *nfp_app_cpp(struct nfp_app *app)
> +{
> +	return app->cpp;
> +}
> +
> +struct nfp_pf *nfp_app_pf(struct nfp_app *app)
> +{
> +	return app->pf;
> +}

Don't create real function calls just to dereference pointers
like this.

Instead, if you absolutely _must_ do stuff like this, put it into
inline functions in a header file so that there is no overhead.

But honestly I would just make the core dereference the struct members
directly in the code and do away with these helpers.

Thanks.
