From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: use helper function to get rid of
 redundancy
Date: Sun, 1 Jun 2014 11:53:20 -0600
Message-ID: <20140601175320.GC20143@mail.gmail.com>
References: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
 <20140601072655.GA12277@omega>
 <20140601142317.GA19754@mail.gmail.com>
 <20140601143550.GA13168@omega>
 <20140601153546.GA20143@mail.gmail.com>
 <20140601163926.GA1527@omega>
 <20140601174929.GB20143@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:63179 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaFARxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 13:53:30 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so2659837pdi.30
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 10:53:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140601174929.GB20143@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sun, 01 Jun 2014 11:49:29 -0600
>
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Sun, 01 Jun 2014 18:39:28 +0200
> >
> > > You mean something like the following will be less confusing?
> > 
> > Yes that's less but there are issues and I don't see any reason why we
> > should do that.
> > 
> > > 
> > > diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
> > > index 4517b149ed07..06b494bacc44 100644
> > > --- a/drivers/net/ieee802154/at86rf230.c
> > > +++ b/drivers/net/ieee802154/at86rf230.c
> > > @@ -602,20 +602,21 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
> > >  {
> > >  	int rc;
> > >  
> > > -	if (channel == 0)
> > > -		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 0);
> > > -	else
> > > -		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 1);
> > > +	if (channel)
> > > +		channel = 1;
> > > +
> > > +	rc = at86rf230_write_subreg(lp, SR_SUB_MODE, channel);
> > >  	if (rc < 0)
> > >  		return rc;
> > >  
> > 
> > First:
> > 
> > This will break the at86rf212_set_channel function. At the end of this
> > function we need the channel parameter and you overwrite it here.
> > At the end of this function stands:
> > 
> > "return at86rf230_write_subreg(lp, SR_CHANNEL, channel);"
> 
> You are right, but we can:
> 
> 	if (channel)
> 		rc = 1;
> 
> 	rc = at86rf230_write_subreg(lp, SR_SUB_MODE, rc);

Obviously:

	int rc = 0;
