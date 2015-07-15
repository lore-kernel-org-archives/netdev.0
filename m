From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Wed, 15 Jul 2015 16:54:08 +0900
Message-ID: <20150715075406.GA25954@vergenet.net>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bChu5sAKpU5tUkENfWZMhaWSs3EQZeggUxR=BjKSOqOeg@mail.gmail.com>
 <20150715044521.GA7603@vergenet.net>
 <CAE4R7bBH3dTfivKqo9qzRVhtpUiDzGdDmoeceY5YBq6A3VR03g@mail.gmail.com>
 <20150715063453.GB7603@vergenet.net>
 <CAE4R7bAy4WKaScamnJJR-bQR4n+=sqKBoR7B=saXCY989+2+3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35938 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbGOHyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:54:18 -0400
Received: by pachj5 with SMTP id hj5so19859828pac.3
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 00:54:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAy4WKaScamnJJR-bQR4n+=sqKBoR7B=saXCY989+2+3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 12:18:20AM -0700, Scott Feldman wrote:
> On Tue, Jul 14, 2015 at 11:34 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > On Tue, Jul 14, 2015 at 10:32:54PM -0700, Scott Feldman wrote:
> 
> >> > @@ -5263,11 +5301,16 @@ static int rocker_port_master_changed(struct net_device *dev)
> >> >          * 3. Other, e.g. being added to or removed from a bond or openvswitch,
> >> >          *    in which case nothing is done
> >> >          */
> >>
> >> Maybe comment above needs adjusting?
> >
> > Indeed, sorry for missing that.
> > How about this?
> >
> >
> >         /* There are currently five cases handled here:
> >          * 1. Joining a bridge
> >          * 2. Joining a Open vSwitch datapath
> >          * 3. Leaving a previously joined bridge
> >          * 4. Leaving a previously joined Open vSwitch datapath
> >          * 5. Other, e.g. being added to or removed from a bond,
> >          *    in which case nothing is done
> >          */
> 
> Seems like one of those comments that needs adjusting each time the
> code changes, which isn't good.  Maybe just kill the comment or write
> in a generic way saying what code is doing.  Code seems obvious enough
> to me to not require a comment.

My purpose in adding the comment in the first place was
to document the "other" case, as it wasn't handled and thus
didn't seem obvious.

Perhaps something like this would work.

	/* N.B: Do nothing if the type of master is not supported */
