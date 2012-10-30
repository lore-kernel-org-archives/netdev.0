From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vxlan: allow a user to set TTL value
Date: Tue, 30 Oct 2012 13:54:27 -0700
Message-ID: <20121030135427.367c90cb@nehalam.linuxnetplumber.net>
References: <1351628836-23094-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37442 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934072Ab2J3UzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 16:55:21 -0400
In-Reply-To: <1351628836-23094-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Oct 2012 21:27:16 +0100
Vincent Bernat <bernat@luffy.cx> wrote:

> "ip link add ... type vxlan ... ttl X" allows a user to set the TTL
> used by a VXLAN for encapsulation. The provided value was ignored by
> vxlan module and the default value of 1 was used when encapsulating
> multicast packets.
> 
> Signed-off-by: Vincent Bernat <bernat@luffy.cx>
> ---
>  drivers/net/vxlan.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 607976c..030559d 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1107,6 +1107,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  	if (data[IFLA_VXLAN_TOS])
>  		vxlan->tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
>  
> +	if (data[IFLA_VXLAN_TTL])
> +		vxlan->ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
> +
>  	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
>  		vxlan->learn = true;
>  
