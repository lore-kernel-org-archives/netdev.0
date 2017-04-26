From: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Wed, 26 Apr 2017 19:52:32 +0300
Message-ID: <1493225552.3165.5.camel@linux.intel.com>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
         <28530.1492534783@obiwan.sandelman.ca>
         <11cf222a-0c1f-4136-091d-719ee68824e1@pengutronix.de>
         <383.1493218546@dooku.sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Richardson <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>,
        Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <383.1493218546-VaGMqW6d0iXFptTlUKWvmrDks+cytr/Z@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Wed, 2017-04-26 at 10:55 -0400, Michael Richardson wrote:
> Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> wrote:
>     >> In a classic SVR4 STREAMS works, it would have been just
> another
>     >> module.  (No, I'm not a fan of *STREAMS* or of SVR4 in
> general,
>     >> although I liked some of the ideas).
>     >>
> 
>     > ok, I see you complain about "having a virtual on top of wpan
>     > interface", or?
> 
>     > I wanted to talk at first about the queue handling which is
> introduced
>     > when 6LoWPAN is not a virtual interface anymore. Or do you want
> to have
>     > a queue in front of 6lowpan adaptation (see other mail reply
> with ASCII
>     > graphics).
> 
> I would like to have a single queue, as close to the hardware as
> possible,
> such that BQL can do it's thing easily.  Should we rethink outgoing
> fragment
> handling for 6lowpan?  Clearly the BT people had a need.
> I don't think they've had a chance to respond to your complaints.

Note that the BT fragmentation (or actually it is called segmentation
in BT) is totally different what 802.15.4 is doing. I do not think
there is any need to add fragmentation handling into 6lo.

Actually the 6lowpan kernel module could probably be simplified to be a
library. We did this in Zephyr where we have compress() and
uncompress() functions that do all the magic.  

> 
>     > We can change that you can run multiple interfaces on one
>     > PHY. Currently we just allow one, because address filtering.
> Disable
>     > address filtering
>     > we will loose ACK handling on hardware.
> 
> Yes, that's a limitation of some hardware, and if you enable multiple
> PANIDs,
> that might be the consequence....
> 
>     > I can try to implement all stuff in software "for fun, maybe
> see what
>     > we can do to handle ACK in software, etc" Then you can run
> multiple
> 
> I'm not asking you to do it, I'm asking, now that we've gotten to a
> certain
> point, we have a better idea what the various requirements are, and
> can we
> re-evaluate things and maybe tweak some things.
> 
> --
> ]               Never tell me the odds!                 | ipv6 mesh
> networks [
> ]   Michael Richardson, Sandelman Software Works        | network
> architect  [
> ]     mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org  http://www.sandelman.ca/        |   ruby on
> rails    [
> 


Cheers,
Jukka
