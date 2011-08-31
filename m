From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Wed, 31 Aug 2011 17:58:49 +0200
Message-ID: <20110831175849.328192b8@alice>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
	<1314802836-9862-2-git-send-email-mschmidt@redhat.com>
	<201108311816.30468.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: "Vlad Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756287Ab1HaP6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:58:54 -0400
In-Reply-To: <201108311816.30468.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 18:16:30 +0300 Vlad Zolotarov wrote:
> On Wednesday 31 August 2011 18:00:34 Michal Schmidt wrote:
> >  	if (bnx2x_reload) {
> > -		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
> > +		if (bp->recovery_state == BNX2X_RECOVERY_DONE) {
> > +			/*
> > +			 * Cheat! Normally dev->features will be
> > set after we
> > +			 * return, but that's too late. We need to
> > know how to
> > +			 * configure the NIC when reloading it, so
> > update
> > +			 * the features early.
> > +			 */
> > +			dev->features = features;
> >  			return bnx2x_reload_if_running(dev);
> 
> NACK 
> 
> This is bogus - what if bnx2x_reload_if_running(dev)
> (bnx2x_nic_load()) failes? The original dev->features would be
> lost... 

Well, yes, but since the NIC would be now not working, do we really
care about its features? :-)

Michal
