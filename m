From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is
 permitted on ingress
Date: Thu, 20 Dec 2012 07:27:11 +0000 (UTC)
Message-ID: <kaueke$69b$1@ger.gmane.org>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
 <1355939304-21804-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59307 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843Ab2LTH1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 02:27:25 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TlaXX-0005wq-TT
	for netdev@vger.kernel.org; Thu, 20 Dec 2012 08:27:35 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:27:35 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:27:35 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Dec 2012 at 17:48 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> +static inline u16 br_get_vlan(const struct sk_buff *skb)
> +{
> +	u16 tag;
> +
> +	if (vlan_tx_tag_present(skb))
> +		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
> +
> +	if (vlan_get_tag(skb, &tag))
> +		return 0;
> +
> +	return tag & VLAN_VID_MASK;
> +}
> +

Nitpick:
The name br_get_vlan() can easily confuse people with br_vlan_find().

Also, this function looks like not bridge-specific, how about moving
it to if_vlan.h?
