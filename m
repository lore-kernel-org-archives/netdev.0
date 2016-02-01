From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Mon, 1 Feb 2016 15:32:41 +0300
Message-ID: <56AF5069.9090703@cogentembedded.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:36356 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbcBAMco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 07:32:44 -0500
Received: by mail-lb0-f176.google.com with SMTP id dx2so73788512lbd.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 04:32:44 -0800 (PST)
In-Reply-To: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/1/2016 12:37 AM, Tom Herbert wrote:

> Call get_unaligned_be32 when we access 32-bit fields in
> __skb_flow_dissect. At the beginning check for unlikely case of
> 1-byte aligned packet.
>
> Note that flow_dissector may be asked to parse packet unaligned
> fields in two instances:
>
> 1) Packet from a driver which is aligned to Ethernet header
>     (2-byte alignment)
> 2) Parsing inner headers of a received GRE-TEB packet
>
> Testing: Ran super_netperf tests did not see a regression. This was on
> x86 which does not have problems with unaligned data.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   net/core/flow_dissector.c | 19 ++++++++++++++-----
>   1 file changed, 14 insertions(+), 5 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index d79699c..1c64a1a 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
[...]
> @@ -116,6 +116,10 @@ EXPORT_SYMBOL(__skb_flow_get_ports);
>    * by flow_dissector from either the skbuff or a raw buffer specified by the
>    * rest parameters.
>    *
> + * This function does not assume 4-byte alignment, but it does assume 2-byte
> + * alignment (false is returned for 1-byte alignment). get_unaligned_be32
> + * is called to get thirty-two values out of the packet.

    32-bit, maybe?

[...]

MBR, Sergei
