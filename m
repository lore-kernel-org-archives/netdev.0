From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH 1/2] ipv6: add sysctl_mld_qrv to configure query
 robustness variable
Date: Tue, 2 Sep 2014 09:57:54 -0300
Message-ID: <20140902125754.GB2779@t520.home>
References: <aa72acbd19015e6db6b2d425fb6ebf6a8fa9c3b5.1409601046.git.hannes@stressinduktion.org>
 <20140902000554.GA7909@t520.home>
 <1409650342.22584.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbaIBM6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 08:58:06 -0400
Content-Disposition: inline
In-Reply-To: <1409650342.22584.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 11:32:22AM +0200, Hannes Frederic Sowa wrote:
> Hi Flavio,
> 
> On Mo, 2014-09-01 at 21:05 -0300, Flavio Leitner wrote:
> > Hi Hannes,
> > 
> > On Mon, Sep 01, 2014 at 09:55:34PM +0200, Hannes Frederic Sowa wrote:
> > > This patch adds a new sysctl_mld_qrv knob to configure the mldv1/v2 query
> > > robustness variable. It specifies how many retransmit of unsolicited mld
> > > retransmit should happen. Admins might want to tune this on lossy links.
> > > 
> > > Also reset mld state on interface down/up, so we pick up new sysctl
> > > settings during interface up event.
> > > 
> > > IPv6 certification requests this knob to be available.
> > > 
> > > I didn't make this knob netns specific, as it is mostly a setting in a
> > > physical environment and should be per host.
> > > 
[...]
> > > @@ -1196,7 +1197,7 @@ static void mld_update_qrv(struct inet6_dev *idev,
> > >  	if (mlh2->mld2q_qrv > 0)
> > >  		idev->mc_qrv = mlh2->mld2q_qrv;
> > >  
> > > -	if (unlikely(idev->mc_qrv < 2)) {
> > > +	if (unlikely(idev->mc_qrv < MLD_QRV_DEFAULT)) {
> > >  		net_warn_ratelimited("IPv6: MLD: clamping QRV from %u to %u!\n",
> > >  				     idev->mc_qrv, MLD_QRV_DEFAULT);
> > >  		idev->mc_qrv = MLD_QRV_DEFAULT;
> > 
> > You allow the sysctl to be 1, but here it is limited to 2?
> 
> I wanted to keep limiting the remotely set value to at least 2.
> 
> Is this more reasonable?
> 
> const int min_qrv = min(MLD_QRV_DEFAULT, sysctl_mld_qrv);
> if (unlikely(idev->mc_qrv < min_qrv)) {
>   net_warn_ratelimited(...);
>   idev->mc_qrv = min_qrv;
> }

Yeah, that makes sense to me.

[...]  
> > > +static int one = 1;
> > > +
> > Although that can be reused later for other purposes, it's nice to
> > have a comment telling where that value came from. Since you have
> > defined MLD_QRV_DEFAULT, it helps. Still I didn't know about 
> > rfc6636#section-4.5, so I'd appreciate if you include that info
> > either in ip-sysctl.txt or close to MLD_QRV_DEFAULT.
> 
> I think ip-sysctl.txt is a good place, do you agree?

Yes, I think so.

[...]
> > Actually, maybe that int could be something not specific to ipv6
> > because I believe there are more users of the same thing. That's ok,
> > just a comment and it's not part of this patch.
> 
> Sorry, I did not understand that. ;)
> Do you propose to use one sysctl variable for igmp and mld?

Sorry, I wasn't clear.  I was saying that 'int one' is used in other
places as well. So, it would be better if that integer is somehow
placed in a common place instead.  But that would be a clean up and
certainly not part of this patch.  Your patch is good as is now.

Thanks Hannes!
fbl
