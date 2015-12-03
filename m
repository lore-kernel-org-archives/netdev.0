From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Re: [PATCH v3 1/1] atm: solos-pci: Replace simple_strtol by
 kstrtoint
Date: Thu, 03 Dec 2015 11:34:05 -0500
Message-ID: <1449160445.2645.68.camel@gmail.com>
References: <1449129968-22249-1-git-send-email-clabbe.montjoie@gmail.com>
	 <1449129968-22249-2-git-send-email-clabbe.montjoie@gmail.com>
	 <1449141991.2645.67.camel@gmail.com> <20151203125840.GA30012@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151203125840.GA30012@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-03 at 13:58 +0100, LABBE Corentin wrote:
> On Thu, Dec 03, 2015 at 06:26:31AM -0500, Charles (Chas) Williams wrote:
> > On Thu, 2015-12-03 at 09:06 +0100, LABBE Corentin wrote:
> > > @@ -357,11 +357,11 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
> > >  	if (!str)
> > >  		return -EIO;
> > >  
> > > -	ver = simple_strtol(str, NULL, 10);
> > > -	if (ver < 1) {
> > > +	err = kstrtoint(str, 10, &ver);
> > > +	if (err || ver < 1) {
> > >  		dev_warn(&card->dev->dev, "Unexpected status interrupt version %d\n",
> > >  			 ver);
> > > -		return -EIO;
> > > +		return err;
> > 
> > 
> > If ver < 1 then you might return a 0 here.  Always returning -EIO is
> > probably just fine.
> > 
> 
> Hello
> 
> I think the best solution is to split the test, since returning error code from kstrtoint was asked by David Miller.
> if (err)
> 	return err;
> if (ver < 1)
> 	return -EIO;
> Thanks
> Regards

That's fine.  You just shouldn't return 0 if the ver < 1.  This isn't
timing critical code.
