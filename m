From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 1/4] net/sched: act_mirred: Rename tcfm_ok_push
 to tcfm_mac_header_xmit
Date: Tue, 27 Sep 2016 21:24:20 +0300
Message-ID: <20160927212420.4677e0f2@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-2-git-send-email-shmulik.ladkani@gmail.com>
        <57EA4A3C.8000508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36050 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934832AbcI0SY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 14:24:27 -0400
Received: by mail-wm0-f66.google.com with SMTP id b184so2403092wma.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 11:24:26 -0700 (PDT)
In-Reply-To: <57EA4A3C.8000508@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 27 Sep 2016 12:30:20 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 09/22/2016 03:21 PM, Shmulik Ladkani wrote:
> > From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> >
> > 'tcfm_ok_push' specifies whether a mac_len sized push is needed upon
> > egress to the target device (if action is performed at ingress).
> >
> > Rename it to 'tcfm_mac_header_xmit' as this is actually an attribute of
> > the target device.
> > This allows to decouple the attribute from the action to be taken.
> >
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > ---
> >   include/net/tc_act/tc_mirred.h |  2 +-
> >   net/sched/act_mirred.c         | 10 +++++-----
> >   2 files changed, 6 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
> > index 62770ad..5275158 100644
> > --- a/include/net/tc_act/tc_mirred.h
> > +++ b/include/net/tc_act/tc_mirred.h
> > @@ -8,7 +8,7 @@ struct tcf_mirred {
> >   	struct tc_action	common;
> >   	int			tcfm_eaction;
> >   	int			tcfm_ifindex;
> > -	int			tcfm_ok_push;
> > +	int			tcfm_mac_header_xmit;  
> 
> Since you already touch this here and in patch 2/4 anyway, maybe
> make that a bool along the way?

Ok.
(Thought of it, but my urge to lessen the diff eventually won)

> Perhaps instead of tcfm_mac_header_xmit, tcfm_mac_header_push
> might be a better name?

Don't think so.

Eventually this serves as the decision to either push or pull, so prefer
not to name it as the action (push/pull) but rather what is target
device's property (xmits at mh?).
