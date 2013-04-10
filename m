From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Wed, 10 Apr 2013 18:29:28 +0400
Message-ID: <51657748.2040600@cogentembedded.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com> <1365530913.29336.50.camel@oc1677441337.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:39167 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936832Ab3DJOac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 10:30:32 -0400
Received: by mail-lb0-f177.google.com with SMTP id r10so591047lbi.36
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 07:30:29 -0700 (PDT)
In-Reply-To: <1365530913.29336.50.camel@oc1677441337.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-04-2013 22:08, Sridhar Samudrala wrote:

>> From: Cong Wang <amwang@redhat.com>

>> This reverts commit 9dcc71e1fdbb7aa10d92a3d35e8a201adc84abd0.
>> It apparently breaks my vxlan tests between different namespaces.

> I haven't tried vxlan with network namespaces.
> This patch effects the following 2 code paths
> - when source and destination endpoints are on the same bridge and
>    route short-circuiting is enabled. I guess you are not hitting
>    this path as this is possible only if you specify 'rsc' flag when
>    creating vxlan device.
> - when source and destination endpoints belonging to different vni's
>    are on 2 different bridges on the same host. encap bypass is done
>    in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
>    you must be hitting this path and the following patch should fix
>    it by only doing bypass if the source and dest devices belong to
>    the same net. Can you try it and see if it fixes your tests?

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 9a64715..d53d8cb 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1012,12 +1012,15 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>   		goto tx_error;
>   	}
>
> -	/* Bypass encapsulation if the destination is local */
> -	if (rt->rt_flags & RTCF_LOCAL) {
> +	/* Bypass encapsulation if the destination is local and in the same
> +	   network namespace.
> +	 */

    Note that the preferred multi-line comment style in the networking code is:

/* bla
  * bla
  */

WBR, Sergei
