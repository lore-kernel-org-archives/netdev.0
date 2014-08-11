From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v3 2/3] xen-netback: don't stop dealloc kthread too
 early
Date: Mon, 11 Aug 2014 16:16:51 +0100
Message-ID: <20140811151651.GL3249@zion.uk.xensource.com>
References: <1407751884-9005-1-git-send-email-wei.liu2@citrix.com>
 <1407751884-9005-3-git-send-email-wei.liu2@citrix.com>
 <53E8D94C.7050905@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12469 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993AbaHKPQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 11:16:53 -0400
Content-Disposition: inline
In-Reply-To: <53E8D94C.7050905@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2014 at 03:55:08PM +0100, Zoltan Kiss wrote:
> On 11/08/14 11:11, Wei Liu wrote:
> >@@ -1525,10 +1537,13 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
> >  	/* remove traces of mapped pages and frag_list */
> >  	skb_frag_list_init(skb);
> >  	uarg = skb_shinfo(skb)->destructor_arg;
> >+	/* See comment on set_skb_zerocopy */
> >+	if (uarg->callback == xenvif_zerocopy_callback)
> This condition is not necessary: uarg->callback shouldn't be anything else
> but this xenvif_zerocopy_callback at this point, unless something terribly
> went wrong. In that case we are doomed anyway :)
> 

Right. I was just too cautious.

Wei.
