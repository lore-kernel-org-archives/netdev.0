From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 02/17] openvswitch: Shrink sw_flow_mask by 8
 bytes (64-bit) or 4 bytes (32-bit).
Date: Wed, 08 Jan 2014 01:36:38 +0400
Message-ID: <52CC7366.4050206@cogentembedded.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com> <1389053776-62865-3-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:60416 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbaAGVgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:36:39 -0500
Received: by mail-lb0-f178.google.com with SMTP id c11so707221lbj.9
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 13:36:37 -0800 (PST)
In-Reply-To: <1389053776-62865-3-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.01.2014 4:16, Jesse Gross wrote:

> From: Ben Pfaff <blp@nicira.com>

> We won't normally have a ton of flow masks but using a size_t to store
> values no bigger than sizeof(struct sw_flow_key) seems excessive.

> This reduces sw_flow_key_range and sw_flow_mask by 4 bytes on 32-bit
> systems.  On 64-bit systems it shrinks sw_flow_key_range by 12 bytes but
> sw_flow_mask only by 8 bytes due to padding.

> Compile tested only.

> Signed-off-by: Ben Pfaff <blp@nicira.com>
> Acked-by: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>   net/openvswitch/flow.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index 1510f51..176406d 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -122,8 +122,8 @@ struct sw_flow_key {
>   } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
>
>   struct sw_flow_key_range {
> -	size_t start;
> -	size_t end;
> +	unsigned short int start;
> +	unsigned short int end;

    *short int* seems somewhat ambiguous, no?

WBR, Sergei
