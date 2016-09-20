From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Tue, 20 Sep 2016 07:36:02 +0300
Message-ID: <20160920073602.1d7ec740@halley>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
        <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
        <20160919230454.08e58116@halley>
        <CAOrHB_Dy3osOea19e+iTxHFpCgJOYe1fUJJnaN-PB-hOq0-rmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38905 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbcITEgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 00:36:13 -0400
Received: by mail-wm0-f47.google.com with SMTP id l132so12704092wmf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 21:36:12 -0700 (PDT)
In-Reply-To: <CAOrHB_Dy3osOea19e+iTxHFpCgJOYe1fUJJnaN-PB-hOq0-rmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 19 Sep 2016 13:46:10 -0700 pravin shelar <pshelar@ovn.org> wrote:
> On Mon, Sep 19, 2016 at 1:04 PM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
> > Hi Pravin,
> >
> > On Sun, 18 Sep 2016 13:26:30 -0700 pravin shelar <pshelar@ovn.org> wrote:  
> >> > +++ b/net/core/skbuff.c
> >> > @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
> >> >         } else {
> >> >                 if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
> >> >                               skb->protocol != htons(ETH_P_8021AD)) ||
> >> > -                            skb->len < VLAN_ETH_HLEN))
> >> > +                            skb->mac_len < VLAN_ETH_HLEN))  
> >>
> >> There is already check in __skb_vlan_pop() to validate skb for a vlan
> >> header. So it is safe to drop this check entirely.  
> >
> > Yep, I submitted a v2 with your suggestion, however I withdrew it, as
> > there is a slight behavior difference noticable by 'skb_vlan_pop' callers.
> >
> > Suppose the rare case where skb->len is too small.
> >
> > pre:
> >   skb_vlan_pop returns 0 (at least for the correct tx path).
> >   Meaning, callers do not see it as a failure.
> > post:
> >   skb_ensure_writable fails (!pskb_may_pull), therefore -ENOMEM returned
> >   to the callers of 'skb_vlan_pop'.
> >
> > For ovs, it means do_execute_actions's loop is terminated, no further
> > actions are executed, and skb gets freed.
> >
> > For tc act vlan, it means skb gets dropped.
> >
> > This actually makes sense, but do we want to present this change?
> >  
> I think this is correct behavior over existing code.

Ok.
I'll submit a v3 identical to v2 but with proper statement of this
behavior change in the commit log.

Thanks.
