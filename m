From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/23] netfilter: nft_ct: load both IPv4 and IPv6
 conntrack modules for NFPROTO_INET
Date: Fri, 10 Jan 2014 19:42:36 +0000
Message-ID: <20140110194235.GA9253@macbook.localnet>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
 <1389314142-17969-9-git-send-email-pablo@netfilter.org>
 <52D05AC6.20000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61813 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758009AbaAJTmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:42:40 -0500
Content-Disposition: inline
In-Reply-To: <52D05AC6.20000@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 11:40:38PM +0300, Sergei Shtylyov wrote:
> On 01/10/2014 03:35 AM, Pablo Neira Ayuso wrote:
> 
> >From: Patrick McHardy <kaber@trash.net>
> 
> >The ct expression can currently not be used in the inet family since
> >we don't have a conntrack module for NFPROTO_INET, so
> >nf_ct_l3proto_try_module_get() fails. Add some manual handling to
> >load the modules for both NFPROTO_IPV4 and NFPROTO_IPV6 if the
> >ct expression is used in the inet family.
> 
> >Signed-off-by: Patrick McHardy <kaber@trash.net>
> >Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> >---
> >  net/netfilter/nft_ct.c |   39 ++++++++++++++++++++++++++++++++++++---
> >  1 file changed, 36 insertions(+), 3 deletions(-)
> 
> >diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
> >index 955f4e6..3727a32 100644
> >--- a/net/netfilter/nft_ct.c
> >+++ b/net/netfilter/nft_ct.c
> [...]
> >+static void nft_ct_l3proto_module_put(uint8_t family)
> >+{
> >+	if (family == NFPROTO_INET) {
> >+		nf_ct_l3proto_module_put(NFPROTO_IPV4);
> >+		nf_ct_l3proto_module_put(NFPROTO_IPV6);
> >+	} else
> >+		nf_ct_l3proto_module_put(family);
> 
>    According to Documentation/CodingStyle, there should be {} in the
> *else* arm, as the other arm of *if* statement has it.

I can see you're looking out for the important stuff. I consistently
used this style in nftables so I'm not going to change it here.
