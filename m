From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 0/2] pv6: fix sticky pktinfo behaviour
Date: Fri, 29 Jan 2016 13:36:09 +0100
Message-ID: <56AB5CB9.8040103@stressinduktion.org>
References: <cover.1454066754.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:39155 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151AbcA2MgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 07:36:14 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 178E220A69
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 07:36:14 -0500 (EST)
In-Reply-To: <cover.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2016 12:30, Paolo Abeni wrote:
> The kernel has never enforced the egress interface specified
> via the sticky pktinfo, except briefly between the commits
> 741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
> and
> d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set"),
> but the ping6 tools was unaffected up to iputils-20100214,
> since before it used SO_BINDTODEVICE to enforce the egress
> interface.

I think because of the bad situation in terms of uapi and that recently 
behavior switched multiple times in kernel and iputils, enforcing the 
outgoing interface seems to be the right thing to do for me.

Also it matches expected behavior by ping6. Treating the interface as 
enforced is from a standards PoV the correct thing to do.

Thanks,
Hannes
