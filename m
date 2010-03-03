From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Wed, 3 Mar 2010 18:52:30 +0100
Message-ID: <20100303175229.GB2760@psychotron.redhat.com>
References: <20100303114506.19575pbsu8yz2kjk@hayate.sektori.org>
 <20100303124249.GD2961@psychotron.lab.eng.brq.redhat.com>
 <20100303184256.19122kg5hcqolfgg@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185Ab0CCRwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 12:52:40 -0500
Content-Disposition: inline
In-Reply-To: <20100303184256.19122kg5hcqolfgg@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 03, 2010 at 05:42:56PM CET, jussi.kivilinna@mbnet.fi wrote:
>Hello!
>
>Quoting "Jiri Pirko" <jpirko@redhat.com>:
>
>>+	} else if (mc_count) {
>>+		int size = min(priv->multicast_size, mc_count);
>>+		int i = 0;
>>+
>>+		mc_addrs = kmalloc(size * ETH_ALEN, GFP_ATOMIC);
>...
>>+	if (filter != basefilter)
>>+		goto set_filter;
>>+
>>+	if (mc_count) {
>>+		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
>>+				    mc_count * ETH_ALEN);
>>+		kfree(mc_addrs);
>
>mc_addrs was alloced by with 'size * ETH_ALEN', which might be less
>than mc_count * ETH_ALEN.

Actually it cannot. That's covered by:

if (mc_count > priv->multicast_size) {

This was also in the original code. In that case "size" can be eliminated and
"mc_addrs" can be allocated with "mc_count * ETH_ALEN".

Jussi are you ok with this?

Jirka
>
>Otherwise ok, and rndis_wlan works.
>
> -Jussi
>
