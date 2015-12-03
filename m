From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 1/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Thu, 3 Dec 2015 13:58:40 +0100
Message-ID: <20151203125840.GA30012@Red>
References: <1449129968-22249-1-git-send-email-clabbe.montjoie@gmail.com>
 <1449129968-22249-2-git-send-email-clabbe.montjoie@gmail.com>
 <1449141991.2645.67.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Charles (Chas) Williams" <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449141991.2645.67.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2015 at 06:26:31AM -0500, Charles (Chas) Williams wrote:
> On Thu, 2015-12-03 at 09:06 +0100, LABBE Corentin wrote:
> > @@ -357,11 +357,11 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
> >  	if (!str)
> >  		return -EIO;
> >  
> > -	ver = simple_strtol(str, NULL, 10);
> > -	if (ver < 1) {
> > +	err = kstrtoint(str, 10, &ver);
> > +	if (err || ver < 1) {
> >  		dev_warn(&card->dev->dev, "Unexpected status interrupt version %d\n",
> >  			 ver);
> > -		return -EIO;
> > +		return err;
> 
> 
> If ver < 1 then you might return a 0 here.  Always returning -EIO is
> probably just fine.
> 

Hello

I think the best solution is to split the test, since returning error code from kstrtoint was asked by David Miller.
if (err)
	return err;
if (ver < 1)
	return -EIO;
Thanks
Regards
