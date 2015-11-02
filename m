From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mpls: Don't accept multipath configuration until
 the support is complete
Date: Mon, 2 Nov 2015 22:49:08 +0300
Message-ID: <5637BE34.10304@cogentembedded.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
 <87egg8ryia.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33190 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbKBTtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:49:13 -0500
Received: by lbbec13 with SMTP id ec13so96489656lbb.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 11:49:12 -0800 (PST)
In-Reply-To: <87egg8ryia.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/02/2015 10:29 PM, Eric W. Biederman wrote:

> Currently the multipath code has a nasty failure mode in that it will
> fail to notice link down or administrative device down and will
> instead black hole packets instead of sending them to their nexthop
> destination.
>
> Half the point of multipath is to gracefully handle forwarding path
> failures and as the current code does not handle forwarding failures the
> current code is dangerous to use.
>
> As mpls multipath has never been exported to userspace and as the
> implementation was not complete before the merge window disable the mpls
> multipath code by rejecting all multipath configuration requests.  This
> will give us another kernel development cycle to cleanly sort out the
> issues, without any bad precedents to worry about.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   net/mpls/af_mpls.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index c70d750148b6..893cd2dc3979 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -1162,6 +1162,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>   		{
>   			cfg->rc_mp = nla_data(nla);
>   			cfg->rc_mp_len = nla_len(nla);
> +			/* Fail until multipath support is complete */
> +			goto errout;
>   			break;

    Forgot to delete *break*?

>   		}
>   		default:
>

MBR, Sergei
