From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC net-next 12/22] arp: Inherit metadata dst when creating
 ARP requests
Date: Fri, 10 Jul 2015 21:55:52 +0300
Message-ID: <55A01538.80809@cogentembedded.com>
References: <cover.1436537414.git.tgraf@suug.ch> <85ea0d614578b637ceaef7e76c6a47a37cfe1483.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>, roopa@cumulusnetworks.com,
	rshearma@brocade.com, ebiederm@xmission.com,
	hannes@stressinduktion.org, pshelar@nicira.com, jesse@nicira.com,
	davem@davemloft.net, daniel@iogearbox.net, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36342 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446AbbGJSz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 14:55:57 -0400
Received: by lagc2 with SMTP id c2so267585230lag.3
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 11:55:55 -0700 (PDT)
In-Reply-To: <85ea0d614578b637ceaef7e76c6a47a37cfe1483.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2015 05:19 PM, Thomas Graf wrote:

> If output device wants to see the dst, inherit the dst of the
> original skb and pass it on to generate the ARP request.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>   net/ipv4/arp.c | 71 +++++++++++++++++++++++++++++++++++-----------------------
>   1 file changed, 43 insertions(+), 28 deletions(-)

> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 933a928..3400aea 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -291,6 +291,46 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
>   	kfree_skb(skb);
>   }
>
> +/*
> + *	Create and send an arp packet.
> + */
> +static void arp_send_dst(int type, int ptype, __be32 dest_ip,
> +			 struct net_device *dev, __be32 src_ip,
> +			 const unsigned char *dest_hw,
> +			 const unsigned char *src_hw,
> +			 const unsigned char *target_hw, struct sk_buff *oskb)
> +{
> +	struct sk_buff *skb;
> +
> +	/*
> +	 *	No arp on this interface.
> +	 */

    The networking code, we do multi-line comments this way:

/* bla
  * bla
  */

> +
> +	if (dev->flags&IFF_NOARP)

    Please surround & with spaces.

[...]
> @@ -597,32 +638,6 @@ void arp_xmit(struct sk_buff *skb)
>   EXPORT_SYMBOL(arp_xmit);
>
>   /*
> - *	Create and send an arp packet.
> - */
> -void arp_send(int type, int ptype, __be32 dest_ip,
> -	      struct net_device *dev, __be32 src_ip,
> -	      const unsigned char *dest_hw, const unsigned char *src_hw,
> -	      const unsigned char *target_hw)
> -{
> -	struct sk_buff *skb;
> -
> -	/*
> -	 *	No arp on this interface.
> -	 */
> -
> -	if (dev->flags&IFF_NOARP)
> -		return;

    Ah, you're moving the code...

[...]

WBR, Sergei
