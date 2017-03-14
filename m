From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Tue, 14 Mar 2017 14:42:04 -0700
Message-ID: <20170314144204.20d5c3a5@xeon-e3>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
        <20170314085502.47d48a4e@xeon-e3>
        <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
        <20170314.114837.619141079617104809.davem@davemloft.net>
        <20170314132506.6233b1e7@xeon-e3>
        <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33202 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdCNVmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 17:42:12 -0400
Received: by mail-pf0-f175.google.com with SMTP id w189so75865179pfb.0
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:42:12 -0700 (PDT)
In-Reply-To: <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Mar 2017 14:10:22 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> On Tue, Mar 14, 2017 at 1:25 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Tue, 14 Mar 2017 11:48:37 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> >  
> >> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >> Date: Tue, 14 Mar 2017 17:58:46 +0200
> >>  
> >> > On 14/03/17 17:55, Stephen Hemminger wrote:  
> >> >> On Tue, 14 Mar 2017 17:36:15 +0200
> >> >> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> >> >>  
> >> >>> This patch adds support for ECMP hash policy choice via a new sysctl
> >> >>> called fib_multipath_hash_policy and also adds support for L4 hashes.
> >> >>> The current values for fib_multipath_hash_policy are:
> >> >>>  0 - layer 3 (default)
> >> >>>  1 - layer 4
> >> >>> If there's an skb hash already set and it matches the chosen policy then it
> >> >>> will be used instead of being calculated (currently only for L4).
> >> >>> In L3 mode we always calculate the hash due to the ICMP error special
> >> >>> case, the flow dissector's field consistentification should handle the
> >> >>> address order thus we can remove the address reversals.
> >> >>>
> >> >>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>  
> >> >>
> >> >> It is good to see ECMP come back from the grave.
> >> >> Linux used to support it long ago but was abandoned after it was unstable
> >> >> and removed from iproute2 in 2012.
> >> >>
> >> >> The old API was through route attributes which makes more sense than
> >> >> doing it with sysctl. It makes more sense to use netlink instead.
> >> >> Therefore please go back and do something like the old API rather than doing it through
> >> >> sysctl.
> >> >>  
> >> >
> >> > That's what my initial version did, but this was discussed during NetConf in Seville
> >> > and it was decided that it's best to make a global sysctl, thus the change.  
> >>
> >> Correct, we discussed this, and we all agreed to only have a sysctl for now.  
> >
> > Why? If you are going to have private discussions please post the rationale
> > in public.  
> 
> Stephen, is there any reason to have a per ecmp route multipath algo
> selection ?.
> All platforms have a global multipath selection algo. I also don't see
> routing daemons ready or willing to specify a per ecmp route multipath
> selection algo attribute.

There is no compelling reason to make the attribute per route. But the
issue is more that configuration through sysctl's is problematic. It doesn't
fit into the standard API paradigm. Sysctl's are like routing patches not
part of the real CLI. Trying to trap sysctl's for things like switchedev
offload is particularly problematic. I can see the case for either way,
and don't have a fixed opinion.

The bigger discussion is trying to keep a record of the rationale for decisions
such that there isn't buried tribal knowledge. This is why Dave has always been
quite insistent on having discussions on the mailing list. There doesn't seem to
be a good long term record other than Documentation/networking or commit logs.
