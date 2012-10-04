From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vxlan: use ether header as fallback hash
Date: Thu, 04 Oct 2012 19:07:56 +0200
Message-ID: <1349370476.16011.84.camel@edumazet-glaptop>
References: <20121001223232.566037595@vyatta.com>
	 <20121001223254.349753999@vyatta.com>
	 <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
	 <20121003213906.09b57539@nehalam.linuxnetplumber.net>
	 <CAEP_g=8F_s3H4MCBf=xKWdASdtpZ7V_tOSGtZpv7ONULegP4ow@mail.gmail.com>
	 <20121004094333.748158e2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54050 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453Ab2JDRIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 13:08:01 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so452881bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 10:08:00 -0700 (PDT)
In-Reply-To: <20121004094333.748158e2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 09:43 -0700, Stephen Hemminger wrote:
> On Thu, 4 Oct 2012 09:27:14 -0700
> Jesse Gross <jesse@nicira.com> wrote:

> > > +static u16 vxlan_flow_hash(struct sk_buff *skb)
> > > +{
> > > +       u16 hash = skb_get_rxhash(skb);
> > > +
> > > +       if (!hash)
> > > +               hash = jhash(skb->data, 3, skb->protocol);
> > 
> > Shouldn't this be jhash2 for words?
> 
> No. for a couple of reasons. First, the ethernet header may not be aligned.
> Second we want to get source/destination and type.  The source/destination
> is 12 bytes (3 words) and the ether type is already in skb->protocol.

jhash(skb->data, 12, initval)
