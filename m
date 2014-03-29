From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 05/17] ixgb: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 06:00:19 -0700
Message-ID: <1396098019.3616.1.camel@joe-AO722>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <73d3fb2312cec80d7891f8da2f7089b8c4752f9f.1396090802.git.romieu@fr.zoreil.com>
	 <1396097224.3122.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0087.hostedemail.com ([216.40.44.87]:35860 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751562AbaC2NAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 09:00:23 -0400
In-Reply-To: <1396097224.3122.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-29 at 05:47 -0700, Joe Perches wrote:
> On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> > struct ixgb_adapter *adapter, struct sk_buff *skb)
> >         if (likely(skb_is_gso(skb))) {
> >                 struct ixgb_buffer *buffer_info;
> >                 struct iphdr *iph;
> > +               int err;
> >  
> > -               if (skb_header_cloned(skb)) {
> > -                       err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
> > -                       if (err)
> > -                               return err;
> > -               }
> > +               err = skb_cow_head(skb, 0);
> > +               if (err < 0)
> > +                       return err
> 
> It seems in many instances you're adding
> an unnecessary declaration of err that
> shadows an already declared err

I take back the many.  This seems to be the only one.
