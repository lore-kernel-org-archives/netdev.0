From: Simon Horman <simon.horman@netronome.com>
Subject: Re: Hardware capabilities and bonding offload
Date: Tue, 17 Nov 2015 14:03:51 -0800
Message-ID: <20151117220349.GA7762@penelope.isobedori.kobe.vergenet.net>
References: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com>
 <20151116153032.GC2217@nanopsycho.orion>
 <5649FFF3.9080401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35628 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbKQWDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 17:03:54 -0500
Received: by pacej9 with SMTP id ej9so21257772pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 14:03:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5649FFF3.9080401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 08:10:27AM -0800, John Fastabend wrote:
> On 15-11-16 07:30 AM, Jiri Pirko wrote:
> > Mon, Nov 16, 2015 at 10:29:12AM CET, pjonnala@broadcom.com wrote:
> >> Hello,
> >>
> >> I am looking to offload bond interfaces to hardware for forwarding.  Linux allows for configuring 
> >> a variety of parameters on bonds or slave interfaces.  Not all configurations can be offloaded to 
> >> hardware.  For example, certain hardware cannot support bonds with mode of adaptive load balancing.
> >>
> >> When such a configuration is provided by user, we have two options at hand (for platforms supporting
> >> hardware offloads):
> >>
> >> 1. Reject the configuration.  
> >>
> >> 2. Handle the bond interface in software.  In a scenario where this bond interface is part
> >> of a bridge interface, for simplicity purpose, all other interfaces in the bridge need to be 
> >> handled in software - which results in a very low packet processing performance.
> > 
> > Although it might sound intriguing to fallback to sw here, it makes no
> > sense and user certainly does not want that. For example in case of our
> > HW, we have 100gbit forwarding which would be degraded to ~1gbit (for one
> > port pair). Another thing is that for some HW this mignt not be even
> > possible. In our case it would be very complicated.
> > 
> > I believe that the correct approach is to let driver decide if the
> > configuration is acceptable or not and reject it in case it is not.
> > 
> 
> +1 I agree the best approach is to throw a hard error and reject
> it if there is no mapping on to the hardware. This lets your
> management software propagate that error up so you can handle it
> correctly at higher levels in the stack.
> 
> You could if needed add a bit to enable setup in software only
> if that is needed.

FWIW, I agree that such a scheme ought to cover the bases.
But perhaps it would be best to old off on adding the software only
bit until a use-case arises. John, perhaps you already have one?
