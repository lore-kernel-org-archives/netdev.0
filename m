From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Sun, 25 May 2008 17:31:42 +0400
Message-ID: <20080525133142.GA25901@2ka.mipt.ru>
References: <20080523120041.GA16850@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1951@SDCEXCHANGE01.ad.amcc.com> <20080525130023.GA27792@2ka.mipt.ru> <20080525.060434.193707056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kchudgar@amcc.com, kchudgar.linux@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58545 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbYEYNbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 09:31:48 -0400
Content-Disposition: inline
In-Reply-To: <20080525.060434.193707056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2008 at 06:04:34AM -0700, David Miller (davem@davemloft.net) wrote:
> > If it is not convenient to use such scheme, you can always put data
> > into pages and then copy tiny bit into skb->data to be able to
> > specify IP layer protocol, all the rest system will do for itself
> > via pskb_may_copy() if needed.
> 
> The network input uses "pskb_may_pull()" not "pskb_may_copy()" :-)

For those who like pskb_may_copy() name, here is a patch :)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bbd8d00..1fb5723 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -990,6 +990,11 @@ static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
 	return __pskb_pull_tail(skb, len-skb_headlen(skb)) != NULL;
 }
 
+static inline int pskb_may_copy(struct sk_buff *skb, unsigned int len)
+{
+	return pskb_may_pull(skb, len);
+}
+
 /**
  *	skb_headroom - bytes at buffer head
  *	@skb: buffer to check


-- 
	Evgeniy Polyakov
