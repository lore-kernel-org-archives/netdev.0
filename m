From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next 2/2] flow_dissector: dissect
 tunnel info
Date: Mon, 2 Oct 2017 22:04:09 +0200
Message-ID: <20171002200408.GA20877@netronome.com>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
 <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
 <CALx6S35DpMWdLVWKSoRdsfROM7=A2p9pLi7n2fMtmqwhSEh5wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:53676 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdJBUEO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 16:04:14 -0400
Received: by mail-wm0-f42.google.com with SMTP id q132so12800894wmd.2
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 13:04:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35DpMWdLVWKSoRdsfROM7=A2p9pLi7n2fMtmqwhSEh5wQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 12:36:33PM -0700, Tom Herbert wrote:
> On Mon, Oct 2, 2017 at 1:41 AM, Simon Horman <simon.horman@netronome.com> wrote:
> > Move dissection of tunnel info from the flower classifier to the flow
> > dissector where all other dissection occurs.  This should not have any
> > behavioural affect on other users of the flow dissector.

...

> > +static void
> > +__skb_flow_dissect_tunnel_info(const struct sk_buff *skb,
> > +                              struct flow_dissector *flow_dissector,
> > +                              void *target_container)
> > +{
> > +       struct ip_tunnel_info *info;
> > +       struct ip_tunnel_key *key;
> > +
> > +       /* A quick check to see if there might be something to do. */
> > +       if (!dissector_uses_key(flow_dissector,
> > +                               FLOW_DISSECTOR_KEY_ENC_KEYID) &&
> > +           !dissector_uses_key(flow_dissector,
> > +                               FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) &&
> > +           !dissector_uses_key(flow_dissector,
> > +                               FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) &&
> > +           !dissector_uses_key(flow_dissector,
> > +                               FLOW_DISSECTOR_KEY_ENC_CONTROL) &&
> > +           !dissector_uses_key(flow_dissector,
> > +                               FLOW_DISSECTOR_KEY_ENC_PORTS))
> > +               return;
> 
> This complex conditional is now in the path of every call to flow
> dissector regardless of whether a classifier is enabled or tunnels
> are. What does the assembly show in terms of number of branches? Can
> we at least get this down to one check (might be a use case for
> FLOW_DISSECTOR_F_FLOWER ;-) ), or even better use the static key when
> encap or is enabled?

Hi Tom,

it appears to me (a little to my surprise but I did check before
posting) that the compiler turns the above into a single comparison.

$ gcc --version
gcc (Debian 4.9.2-10) 4.9.2
Copyright (C) 2014 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
