From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net v2 2/2] mpls: fix mpls route deletes to not check
 for route scope
Date: Wed, 27 May 2015 20:46:31 +0100
Message-ID: <55661F17.5050504@brocade.com>
References: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<vivek@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:28766 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbbE0TrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 15:47:25 -0400
In-Reply-To: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/05/15 19:37, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Ignore scope for route del messages
>
> Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Reviewed-by: Robert Shearman <rshearma@brocade.com>

> ---
>   net/mpls/af_mpls.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 7b3f732..f4eb0dd 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -693,8 +693,10 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>   	 * (or source specific address in the case of multicast)
>   	 * all addresses have universal scope.
>   	 */
> -	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> -		goto errout;
> +	if (nlh->nlmsg_type != RTM_DELROUTE &&
> +		rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> +			goto errout;
> +
>   	if (rtm->rtm_type != RTN_UNICAST)
>   		goto errout;
>   	if (rtm->rtm_flags != 0)
>
