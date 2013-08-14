From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch] rtnetlink: remove an unneeded test
Date: Wed, 14 Aug 2013 12:35:24 -0700
Message-ID: <8761v8aww3.fsf@xmission.com>
References: <20130814093542.GC521@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45128 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab3HNTfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 15:35:48 -0400
In-Reply-To: <20130814093542.GC521@elgon.mountain> (Dan Carpenter's message of
	"Wed, 14 Aug 2013 12:35:42 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> We know that "dev" is a valid pointer at this point, so we can remove
> the test and clean up a little.

Quite right.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 618dbe4..e7e058e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1867,10 +1867,10 @@ replay:
>  		else
>  			err = register_netdevice(dev);
>  
> -		if (err < 0 && !IS_ERR(dev))
> +		if (err < 0) {
>  			free_netdev(dev);
> -		if (err < 0)
>  			goto out;
> +		}
>  
>  		err = rtnl_configure_link(dev, ifm);
>  		if (err < 0)
