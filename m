From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 09:46:08 +0000
Message-ID: <20090616094608.GB6106@ff.dom.local>
References: <4A367E14.4040104@trash.net> <20090616061603.GA4494@ff.dom.local> <20090616071204.GB4494@ff.dom.local> <4A376665.6000801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:47232 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbZFPJqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:46:12 -0400
Received: by bwz9 with SMTP id 9so3904093bwz.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 02:46:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A376665.6000801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 11:31:17AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Tue, Jun 16, 2009 at 06:16:03AM +0000, Jarek Poplawski wrote:
> >   
> >> On 15-06-2009 19:00, Patrick McHardy wrote:
> >>     
> >>> This patch contains the final driver ndo_start_xmit() return
> >>> value fixups. I'm pretty sure I got them all ...
> >>>       
> >
> > ...You should probably revisit wireless/zd1201.c (return 0) btw.
> 
> Whats wrong with that?

I thought you wanted to replace it with NETDEV_TX_OK, but now I see
you leave both variants in the last patch, so I'm not sure...

Jarek P.

@@ -1759,6 +1753,11 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	return 0;
+
+drop:
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+
