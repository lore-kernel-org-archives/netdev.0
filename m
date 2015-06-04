From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 2/6] net: Identfier Locator Addressing module
Date: Thu, 04 Jun 2015 12:02:10 +0200
Message-ID: <1433412130.1805421.286610153.28C55E6E@webmail.messagingengine.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
 <1433361502-3478761-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	agartrell@fb.com, maheshb@google.com, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33307 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752683AbbFDKCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 06:02:12 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 14766211AF
	for <netdev@vger.kernel.org>; Thu,  4 Jun 2015 06:02:11 -0400 (EDT)
In-Reply-To: <1433361502-3478761-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 3, 2015, at 21:58, Tom Herbert wrote:
> +static u32 hashrnd __read_mostly;
> +static __always_inline void ila_init_secret(void)
> +{
> +       net_get_random_once(&hashrnd, sizeof(hashrnd));
> +}
> +
> +static inline unsigned int ila_hash(u64 id)
> +{
> +       u32 *words = (u32 *)&id;
> +
> +       return jhash_2words(words[0], words[1], hashrnd);
> +}

You can put hashrnd as static variable inside ila_hash and use the
net_get_random_once directly before calling jhash, no need to initialize
the secret during kernel bootup.

Thanks,
Hannes
