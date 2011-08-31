From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Wed, 31 Aug 2011 09:13:43 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097ADE0@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
 <1314802836-9862-2-git-send-email-mschmidt@redhat.com>
 <201108311816.30468.vladz@broadcom.com> <20110831175849.328192b8@alice>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4880 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756665Ab1HaQN5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 12:13:57 -0400
In-Reply-To: <20110831175849.328192b8@alice>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Wednesday, August 31, 2011 6:59 PM
> To: Vladislav Zolotarov
> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Eilon Greenstein;
> mirqus@gmail.com
> Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
> 
> On Wed, 31 Aug 2011 18:16:30 +0300 Vlad Zolotarov wrote:
> > On Wednesday 31 August 2011 18:00:34 Michal Schmidt wrote:
> > >  	if (bnx2x_reload) {
> > > -		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
> > > +		if (bp->recovery_state == BNX2X_RECOVERY_DONE) {
> > > +			/*
> > > +			 * Cheat! Normally dev->features will be
> > > set after we
> > > +			 * return, but that's too late. We need to
> > > know how to
> > > +			 * configure the NIC when reloading it, so
> > > update
> > > +			 * the features early.
> > > +			 */
> > > +			dev->features = features;
> > >  			return bnx2x_reload_if_running(dev);
> >
> > NACK
> >
> > This is bogus - what if bnx2x_reload_if_running(dev)
> > (bnx2x_nic_load()) failes? The original dev->features would be
> > lost...
> 
> Well, yes, but since the NIC would be now not working, do we really
> care about its features? :-)

U r kidding, right? ;)
We care about the consistency in the netdev features state - if we failed 
to configure the requested feature and returned an error on e.g. "ethtool -K ethX lro on"
call, it's expected that a subsequent ethtool -k ethX call won't report the requested
feature (LRO) as set.

Thanks,
vlad

> 
> Michal
