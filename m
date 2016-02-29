From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 14:10:11 +0100
Message-ID: <1456751411.4837.25.camel@redhat.com>
References: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbcB2NKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 08:10:17 -0500
In-Reply-To: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-02-29 at 12:22 +0000, Zhang Shengju wrote:
> If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
> Then at skb_vlan_untag(), it will free skbuff again which cause double
> free.

On skb_reorder_vlan_header() failure, skb_vlan_untag() will call
kfree_skb() using the return value of skb_reorder_vlan_header(), that is
NULL. kfree_skb() is a noop when the argument is NULL.

The current code seams safe.

Paolo
