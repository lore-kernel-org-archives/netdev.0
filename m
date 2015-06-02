From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net iproute2 v3 1/2] mpls: always set type as RTN_UNICAST for route add/deletes
Date: Tue, 02 Jun 2015 16:22:34 -0500
Message-ID: <871thtolet.fsf@x220.int.ebiederm.org>
References: <1433226567-23302-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, davem@davemloft.net,
	rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37404 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbFBV1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:27:38 -0400
In-Reply-To: <1433226567-23302-2-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Mon, 1 Jun 2015 23:29:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Kernel expects type RTN_UNICAST for mpls route/dels

There almost a bug in this patch.  You test req.r.rtm_family just
before the default case of AF_UNSPEC is set to AF_INET.  Which should
not affect anything in this case but is down right confusing to think
about, and could lead to maintenance problems in the future.

Otherwise
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


> Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reviewed-by: Robert Shearman <rshearma@brocade.com> 
> ---
>  ip/iproute.c |    5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 670a4c6..71c088b 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -803,6 +803,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>  	int scope_ok = 0;
>  	int table_ok = 0;
>  	int raw = 0;
> +	int type_ok = 0;
>  
>  	memset(&req, 0, sizeof(req));
>  
> @@ -1095,6 +1096,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>  			    rtnl_rtntype_a2n(&type, *argv) == 0) {
>  				NEXT_ARG();
>  				req.r.rtm_type = type;
> +				type_ok = 1;
>  			}
>  
>  			if (matches(*argv, "help") == 0)
> @@ -1160,6 +1162,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>  		}
>  	}
>  
> +	if (!type_ok && req.r.rtm_family == AF_MPLS)
> +		req.r.rtm_type = RTN_UNICAST;
> +
>  	if (req.r.rtm_family == AF_UNSPEC)
>  		req.r.rtm_family = AF_INET;
