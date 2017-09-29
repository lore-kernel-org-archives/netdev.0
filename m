From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/8] net: dsa: directly fetch switch in
 lan9303_rcv
Date: Fri, 29 Sep 2017 12:02:01 -0700
Message-ID: <e1fcff41-6ee7-e125-c7eb-98f6ba00a62d@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35287 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbdI2TCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 15:02:06 -0400
In-Reply-To: <20170929183635.8122-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> In a single-chip switch fabric, there is no need to fetch the dsa_switch
> structure from the tree, directly use the CPU port's "ds" member.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/tag_lan9303.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
> index 0b9826105e42..f0b51acf36ac 100644
> --- a/net/dsa/tag_lan9303.c
> +++ b/net/dsa/tag_lan9303.c
> @@ -72,11 +72,10 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
>  {
>  	u16 *lan9303_tag;
>  	struct dsa_switch_tree *dst = dev->dsa_ptr;
> -	struct dsa_switch *ds;
> +	struct dsa_port *cpu_dp = dst->cpu_dp;
> +	struct dsa_switch *ds = cpu_dp->ds;
>  	unsigned int source_port;
>  
> -	ds = dst->ds[0];
> -
>  	if (unlikely(!ds)) {
>  		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
>  		return NULL;

Similarly to the patch before, you can probably drop this test, I don't
actually see how we could trigger it.
-- 
Florian
