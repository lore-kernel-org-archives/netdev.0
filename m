From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 08:22:49 -0700
Message-ID: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
References: <20060805054256.14081.74770.stgit@lunar.tarbal.com>
	 <44ED46AA.60004@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff@lime.pobox.com, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"John Ronciak" <john.ronciak@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:50628 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965003AbWHXPWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:22:51 -0400
Received: by wr-out-0506.google.com with SMTP id i28so171748wra
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 08:22:50 -0700 (PDT)
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <44ED46AA.60004@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/06, Jeff Garzik <jgarzik@pobox.com> wrote:
> Jeff@lime.pobox.com wrote:
> > @@ -598,25 +608,7 @@ static void parse_cmdline(int argc, char
> >               }
> >       }
> >
> > -     if (autoneg_wanted == AUTONEG_ENABLE){
> > -             if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
> > -                     advertising_wanted = ADVERTISED_10baseT_Half;
> > -             else if (speed_wanted == SPEED_10 &&
> > -                      duplex_wanted == DUPLEX_FULL)
> > -                     advertising_wanted = ADVERTISED_10baseT_Full;
> > -             else if (speed_wanted == SPEED_100 &&
> > -                      duplex_wanted == DUPLEX_HALF)
> > -                     advertising_wanted = ADVERTISED_100baseT_Half;
> > -             else if (speed_wanted == SPEED_100 &&
> > -                      duplex_wanted == DUPLEX_FULL)
> > -                     advertising_wanted = ADVERTISED_100baseT_Full;
> > -             else if (speed_wanted == SPEED_1000 &&
> > -                      duplex_wanted == DUPLEX_HALF)
> > -                     advertising_wanted = ADVERTISED_1000baseT_Half;
> > -             else if (speed_wanted == SPEED_1000 &&
> > -                      duplex_wanted == DUPLEX_FULL)
> > -                     advertising_wanted = ADVERTISED_1000baseT_Full;
> > -             else
> > +     if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {
>
>
> This will change existing behavior of the tool, AFAICS.
>

That is kinda the point.  The current beahvior only allows the user to
set the autonegotiation advertisement to one setting (i.e 100 Half or
100 Full or 10 Half or 10 Full).  With this patch the user is now able
to determine exactly speed's and duplex's will be advertised for
example, if a user is connected to a hub, they can tell the nic to
only advertise 100 half and 10 half.
The old way of setting autonegotiation was using the following command:
ethtool -s ethx speed 100 duplex full auto on
now the command would be
ethtool -s ethx auto on advertise 0x08
both commands would result in only advertising 100 FULL.

There still needs to be a change made to the man file to reflect the
change in the behavior of ethtool, which I have not done.  But this
patch will allow for greater flexibility in setting autonegotiation
speeds.

-- 
Cheers,
Jeff
