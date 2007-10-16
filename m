From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Tue, 16 Oct 2007 14:53:25 +0200
Message-ID: <4714B445.1020900@trash.net>
References: <1192537921.4480.80.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40216 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbXJPMxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:53:45 -0400
In-Reply-To: <1192537921.4480.80.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

[Can't quote for some reason ..]

I don't think this change is safe since we might loose the
redirect counter and have endless redirect loops. ipip for
example calls skb_realloc_headroom, which clones the skb
when delta > 0, so it seems we really need to copy tc_verd
in skb_clone(). Generally the assumption that drivers don't
clone packets doesn't seem safe.
