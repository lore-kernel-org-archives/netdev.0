From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v1 1/1] pppoe: l2tp: the PPPOX_CONNECTED should be used
 with bit operation
Date: Fri, 19 Aug 2016 22:18:10 +0200
Message-ID: <20160819201810.hos5ptnlwx4fq5i4@alphalink.fr>
References: <1471485543-13149-1-git-send-email-fgao@ikuai8.com>
 <20160818174402.md35bxj4v35uc2bg@alphalink.fr>
 <CA+6hz4oSsVbpNiopMe-CzHyJNwaM-1GzPXMaGKAD5OUuH_EMrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com>, mostrows@earthlink.net,
        jchapman@katalix.com, "David S. Miller" <davem@davemloft.net>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34130 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752435AbcHSUSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 16:18:18 -0400
Content-Disposition: inline
In-Reply-To: <CA+6hz4oSsVbpNiopMe-CzHyJNwaM-1GzPXMaGKAD5OUuH_EMrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 06:58:58AM +0800, Feng Gao wrote:
> inline.
> 
> On Fri, Aug 19, 2016 at 1:44 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Thu, Aug 18, 2016 at 09:59:03AM +0800, fgao@ikuai8.com wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> There are some codes in pppoe and l2tp which use the PPPOX_CONNECTED
> >> as the value including assignment and condition check.
> >> They should keep consistent with other codes.
> >>
> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> >> ---
> >>  v1: Initial Patch
> >>
> >>  drivers/net/ppp/pppoe.c | 2 +-
> >>  net/l2tp/l2tp_ppp.c     | 4 ++--
> >>  2 files changed, 3 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> >> index 4ddae81..684b773 100644
> >> --- a/drivers/net/ppp/pppoe.c
> >> +++ b/drivers/net/ppp/pppoe.c
> >> @@ -697,7 +697,7 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
> >>                       goto err_put;
> >>               }
> >>
> >> -             sk->sk_state = PPPOX_CONNECTED;
> >> +             sk->sk_state |= PPPOX_CONNECTED;
> >>
> > Using plain assignment makes it clear for the reader that other flags
> > are unset. I see no reason for changing this.
> 
> I get you. So I don't modify the PPPOX_DEAD assignment.
> But I am afraid if there is some case that the flag PPPOX_BOUND is set
> before PPPOX_CONNECTED . Then the assignment of "PPPOX_CONNECTED" will
> clear the PPPOX_BOUND flag.
> 
PPPOX_BOUND shouldn't be set here. If the socket hasn't been connected
before, it can't have the BOUND flag (pppox_ioctl(PPPIOCGCHAN) would
fail). But if it was connected, then it'd have to go through the
'/* Delete the old binding */' part of pppoe_connect() first, thus
reseting sk_state to PPPOX_NONE.
