From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 issues
Date: Mon, 23 Jul 2007 14:34:56 -0700
Message-ID: <1185226496.7922.33.camel@dell>
References: <469E78A2.80904@imperialnet.org>
 <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
 <20070719113755.GA1934@hmsreliant.homelinux.net>
 <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell>
 <46A0E9D7.7020904@imperialnet.org> <1184960061.4850.9.camel@dell>
 <46A113BA.7050805@imperialnet.org> <46A342DC.1030305@imperialnet.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>, mcarlson@broadcom.com
To: "patric" <pakar@imperialnet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4824 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765287AbXGWUlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 16:41:36 -0400
In-Reply-To: <46A342DC.1030305@imperialnet.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-22 at 13:43 +0200, patric wrote:
> patric wrote:
> 
> > Hi,
> >
> > Think i got something working for me at least, and the fix is quite 
> > minimal and only downside that i could see from it was that you might 
> > get a small delay when bringing up the interface, but that's probably 
> > better than getting a non-functional interface that reports that it's up.
> >
> > The fix seems to be quite simple with just a random sleep at the end 
> > of  "tg3_setup_fiber_by_hand():"
> >
> >                tw32_f(MAC_MODE, tp->mac_mode);
> >                udelay(40);
> >        }
> >
> > out:
> >        udelay( net_random() % 400 );
> >        return current_link_up;
> > }
> >
> > Not sure that this is a good fix or if it might break on other 
> > systems, but maybe you could have a quick look at that?
> >
> > Regards,
> > Patric
> >
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> Last update on this.
> 
> "udelay( 100 + net_random % 300 )" seems to work much better and i have 
> not had a single problem getting the link up within 10 seconds of a cold 
> or warm-boot, and most often the link comes up directly without any sort 
> of delay instead like before when it could hang for 30 seconds before 
> getting a link, if you even got a link.
> 

We'll have to do some testing to see if we can find a better solution.
Adding up to 400 usec of busy wait is not ideal.  Are you connecting two
5701 fiber cards directly to each other in your setup?

