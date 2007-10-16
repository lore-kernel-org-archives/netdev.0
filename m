From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [NET_DOC] Document some simple rules for actions
Date: Tue, 16 Oct 2007 09:09:42 -0400
Message-ID: <1192540182.4480.99.camel@localhost>
References: <1192538011.4480.84.camel@localhost>
	 <20071016125134.GA11319@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:7763 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbXJPNLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 09:11:03 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1419702rvb
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 06:11:02 -0700 (PDT)
In-Reply-To: <20071016125134.GA11319@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 20:51 +0800, Herbert Xu wrote:

> But I still think the distinction between skb_clone and
> skb_copy_header is wrong.
> 
> When you munge a packet, it's still going to go back up
> the stack and be processed along the same path.  Therefore
> you should be calling pskb_expand_head.

Dang, just noticed i said skb_expand() in the doc - is that the 
issue? I will resend that one patch.
We do call pskb_expand_head() - example look at act_pedit.c

> In other words, this does not explain why skb_copy/pskb_copy
> and skb_copy_expand should differ from skb_clone.  As far as
> I can see all these functions should behave in the same manner
> with respect to tc_verd


We need to avoid actions from infinetely looping (eg when they ask for
being reclassified) in a directed graph. That loop ttl count  must be
reset to zero if we branch, because that is a new directed path. This is
always true and therefore that field must always be reset. 
I have a feeling i am going on a tangent if that doesnt respond to your
comment above.

cheers,
jamal

