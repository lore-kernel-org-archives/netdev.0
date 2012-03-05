From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Mon, 5 Mar 2012 09:09:43 +0100
Message-ID: <OFA70698EF.42F3A042-ONC12579B8.002C0598-C12579B8.002CD5E3@transmode.se>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:43504 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755789Ab2CEIJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 03:09:46 -0500
In-Reply-To: <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 2012/03/05 06:03:50:
>
> On Thu, 1 Mar 2012 19:12:18 +0100
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote:
>
> > min age increment needs to round up its min age tick for all
> > HZ values to guarantee message age is increasing.
> >
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >
> > The bridge list seems very slow so try netdev instead.
> >
> >  net/bridge/br_stp.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> > index a04eeb6..9a8aebd 100644
> > --- a/net/bridge/br_stp.c
> > +++ b/net/bridge/br_stp.c
> > @@ -17,9 +17,9 @@
> >  #include "br_private_stp.h"
> >
> >  /* since time values in bpdu are in jiffies and then scaled (1/256)
> > - * before sending, make sure that is at least one.
> > + * before sending, make sure that is at least one STP tick.
> >   */
> > -#define MESSAGE_AGE_INCR   ((HZ < 256) ? 1 : (HZ/256))
> > +#define MESSAGE_AGE_INCR   ((HZ / 256) + 1)
> >
> >  static const char *const br_port_state_names[] = {
> >     [BR_STATE_DISABLED] = "disabled",
>
> I don't understand why this is required.
>   HZ = 100 then incr = 1
>   HZ = 1000 then incr = 3 (your patch would make it for 4).

Since message age is rounded down, DIV_ROUND_UP(ticks * HZ, STP_HZ), I wanted
to make sure that message age won't decrease or stay the same by adding at least one
STP tick. We did see such age times when we were debugging this. They went away with
both patches applied so there is a chance that only patch 2 is strictly required but
I did not test that combo.

 Jocke
