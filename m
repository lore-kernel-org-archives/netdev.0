From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net: Fix a memmove bug in dev_gro_receive()
Date: Wed, 11 Aug 2010 12:02:10 +0000
Message-ID: <20100811120210.GA24019@ff.dom.local>
References: <1280454855-7893-1-git-send-email-xiaohui.xin@intel.com> <20100802102906.GA8439@ff.dom.local> <F2E9EB7348B8264F86B6AB8151CE2D791BAB3078E0@shsmsx502.ccr.corp.intel.com> <20100803064515.GA6430@ff.dom.local> <F2E9EB7348B8264F86B6AB8151CE2D7920AD46E911@shsmsx502.ccr.corp.intel.com> <20100810083426.GA11509@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45994 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab0HKMCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 08:02:18 -0400
Received: by fxm13 with SMTP id 13so21034fxm.19
        for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 05:02:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100810083426.GA11509@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[was: Re: Is it a possible bug in dev_gro_receive()?]
On Tue, Aug 10, 2010 at 08:34:26AM +0000, Jarek Poplawski wrote:
> On Tue, Aug 10, 2010 at 04:11:54PM +0800, Xin, Xiaohui wrote:
> > Jarek,
> > Seems community agree with your patch more.
> > So may you send out your patch then? Thanks!
> > Some of my related patches still need this fix.
> 
> Hmm... But there was no my patch. Only a tiny, cosmetical suggestion
> to your patch. I'd be glad if you add some credit or my "Acked-by",
> of course. But if you really have a big problem, e.g. you don't like
> my suggestion, please confirm.

Hmm#2... OK, it's probably something with my English, but since it
seems to take too long, here it is. Xiaohui, I hope you'll send your
"Signed-off-by" at least.

Thanks,
Jarek P.

PS: I know, there is a bit too long line...
--------------------------->

>Xin Xiaohui wrote:
> I looked into the code dev_gro_receive(), found the code here:
> if the frags[0] is pulled to 0, then the page will be released,
> and memmove() frags left.
> Is that right? I'm not sure if memmove do right or not, but
> frags[0].size is never set after memove at least. what I think
> a simple way is not to do anything if we found frags[0].size == 0.
> The patch is as followed.
...

This version of the patch fixes the bug directly in memmove.

Reported-by: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ae6543..3721fbb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3143,7 +3143,7 @@ pull:
 			put_page(skb_shinfo(skb)->frags[0].page);
 			memmove(skb_shinfo(skb)->frags,
 				skb_shinfo(skb)->frags + 1,
-				--skb_shinfo(skb)->nr_frags);
+				--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
 		}
 	}
 
