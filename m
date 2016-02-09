From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Tue, 9 Feb 2016 21:18:21 +0300
Message-ID: <56BA2D6D.6090408@cogentembedded.com>
References: <1455036424-6403-1-git-send-email-david@weave.works>
 <1455036424-6403-3-git-send-email-david@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Wragg <david@weave.works>, netdev@vger.kernel.org,
	dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35278 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807AbcBISS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 13:18:26 -0500
Received: by mail-lf0-f41.google.com with SMTP id l143so120868321lfe.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 10:18:25 -0800 (PST)
In-Reply-To: <1455036424-6403-3-git-send-email-david@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2016 07:47 PM, David Wragg wrote:

> Allow the MTU of geneve devices to be set to large values, in order to
> exploit underlying networks with larger frame sizes.
>
> GENEVE does not have a fixed encapsulation overhead (an openvswitch
> rule can add variable length options), so there is no relevant maximum
> MTU to enforce.  A maximum of IP_MAX_MTU is used instead.
> Encapsulated packets that are too big for the underlying network will
> get dropped on the floor.
>
> Signed-off-by: David Wragg <david@weave.works>
> ---
>   drivers/net/geneve.c | 12 +++++++++++-
>   1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 0b14ac3..05cef11 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1039,6 +1039,16 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>   	return geneve_xmit_skb(skb, dev, info);
>   }
>
> +static int geneve_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	/* GENEVE overhead is not fixed, so we can't enforce a more
> +	   precise max MTU. */

    The networking code formats comments:

/* Like
  * this.
  */

> +	if (new_mtu < 68 || new_mtu > IP_MAX_MTU)
> +		return -EINVAL;
> +	dev->mtu = new_mtu;
> +	return 0;
> +}
> +
>   static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
>   {
>   	struct ip_tunnel_info *info = skb_tunnel_info(skb);
[...]

MBR, Sergei
