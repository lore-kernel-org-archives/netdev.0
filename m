From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Fri, 25 Aug 2006 17:28:59 -0700
Message-ID: <9929d2390608251728u3c182abcya76e3139b82101a1@mail.gmail.com>
References: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <20060825194254.7657318f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:24560 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422940AbWHZA3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:29:01 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1027354ugc
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 17:28:59 -0700 (PDT)
To: "Bill Fink" <billfink@mindspring.com>
In-Reply-To: <20060825194254.7657318f.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/25/06, Bill Fink <billfink@mindspring.com> wrote:
> On Thu, 24 Aug 2006, Michael Chan wrote:
>
> > Jeff Kirsher wrote:
> >
> > > The old way of setting autonegotiation was using the
> > > following command:
> > > ethtool -s ethx speed 100 duplex full auto on
> > > now the command would be
> > > ethtool -s ethx auto on advertise 0x08
> > > both commands would result in only advertising 100 FULL.
> > >
> > > There still needs to be a change made to the man file to reflect the
> > > change in the behavior of ethtool, which I have not done.  But this
> > > patch will allow for greater flexibility in setting autonegotiation
> > > speeds.
> >
> > It is more flexible, but less intuitive.  The user now has to
> > remember hex values instead of the more intuitive speed and
> > duplex.  Perhaps we can keep the old method of using speed and
> > duplex, while adding the new method of specifying hex values?
>
> I agree.  Something like:
>
>         ethtool -s ethx auto on advertise mode1+mode2+...+moden
>
> For example:
>
>         ethtool -s ethx auto on advertise 100-half+100-full
>
> to set speed 100 either half or full duplex.
>
> Maybe have some abbreviations such as 100-all (same as above) or
> all-half (for all supported half duplex) or just all (for all supported
> modes), which I suppose is the default.
>
> Just an idea.
>
>                                                 -Bill
>

I agree that using a hex value is less intuitive, but with proper
documentation in the man file it would be easily understood.  It is
also easier to state
ethtool -s ethx autoneg on advertise 0x0F
than it would be to do:
ethtool -s ethx autoneg on advertise 100-half+100-full+10-half+10-full

Not that it is impossible to do, but the code to do the parsing would
not be as clean as it is to use a hex value.  Currently ethtool
already uses numeric values for messagelevel, phyad and sopass.  So I
am not suggesting something completely new.  I have already submitted
a patch to keep the old functionality while adding the new.  Only
thing left for this is to create the manual documentation so that
users can easily understand how to use the functionality.

10-half     = 0x01
10-full      = 0x02
100-half   = 0x04
100-full    = 0x08
1000-half = 0x10 (actually not supported by IEEE standards)
1000-full  = 0x20
auto        = 0x00 or 0x3F

In addition the code already tests the value that the user enters with
what is supported and only displays the supported values.

-- 
Cheers,
Jeff
