From: =?utf-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 22:16:37 +0800
Message-ID: <001c01d172fb$cddc7530$69955f90$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "'Paolo Abeni'" <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5355 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbcB2OQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:16:46 -0500
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2016-02-29 at 12:22 +0000, Zhang Shengju wrote:
> > If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
> > Then at skb_vlan_untag(), it will free skbuff again which cause double
> > free.
> 
> On skb_reorder_vlan_header() failure, skb_vlan_untag() will call
> kfree_skb() using the return value of skb_reorder_vlan_header(), that is
> NULL. kfree_skb() is a noop when the argument is NULL.
> 
> The current code seams safe.
> 
> Paolo
Hi Paolo, even current code is safe, this's still a potential problem. We should make an
assumption that inner function doesn't free skb, and let outside function take care of this.

BRs, 
Shengju
