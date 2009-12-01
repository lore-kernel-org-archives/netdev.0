From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 01 Dec 2009 20:18:09 +0100
Message-ID: <4B156BF1.7060407@gmail.com>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com> <20091201080151.GA6408@ff.dom.local> <20091201084332.GB6408@ff.dom.local> <4B156A94.9030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:63330 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbZLATSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 14:18:14 -0500
Received: by bwz27 with SMTP id 27so3776473bwz.21
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 11:18:19 -0800 (PST)
In-Reply-To: <4B156A94.9030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 12/01/2009 08:12 PM:

> So, as I wrote before, your proposal based on the first variant is
> acceptable to me, but please reconsider the second idea too, e.g.
> done like this:
> 
>                  }
>                  /* this used to be after charge_class but this constelation
>                     gives us slightly better performance */
>                  if (!cl->un.leaf.q->q.qlen) {
>                          htb_deactivate(q, cl);
> +			 if (unlikely(cl->un.leaf.deficit[level] < cl->quantum)) {

Should be:
 +			 if (unlikely(cl->un.leaf.deficit[level] < -cl->quantum)) {

Jarek P.

> +				{ a warning }
> +                      	 	cl->un.leaf.deficit[level] = 0;
> +			 }
>  		 }
>                  htb_charge_class(q, cl, level, skb);
>          }
>          return skb;
>  }
> 

