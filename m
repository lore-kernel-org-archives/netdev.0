From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] geneve: remove use of internal IP header when calling
 IP_ECN_decapsulate
Date: Thu, 17 Sep 2015 16:17:01 -0400
Message-ID: <20150917201701.GG25806@tuxdriver.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
 <CAEP_g=8Hjcae1zrzV2--j6J3rsXfZmexnGsziA3OTmezdLtbkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58522 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbbIQUaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:30:14 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8Hjcae1zrzV2--j6J3rsXfZmexnGsziA3OTmezdLtbkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 12:46:48PM -0700, Jesse Gross wrote:
> On Thu, Sep 17, 2015 at 10:17 AM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> > index da3259ce7c8d..a917ae1cfbf3 100644
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > @@ -178,13 +178,15 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
> >
> >         skb_reset_network_header(skb);
> >
> > -       iph = ip_hdr(skb); /* Now inner IP header... */
> > -       err = IP_ECN_decapsulate(iph, skb);
> > +       if (iph)
> > +               err = IP_ECN_decapsulate(iph, skb);
> 
> It looks like this is now conditional based on !collect_md. I'm not
> sure that we want to have a difference in behavior between the two.

Sure, I can move the iph assignment higher-up and keep the other bits unconditional.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
