From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v3 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Mon, 22 Aug 2016 11:54:26 +0200
Message-ID: <20160822095426.bzyexfethxr45rw6@alphalink.fr>
References: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
 <9423c2ce-fb0c-818c-1b27-d45668f4a015@redfish-solutions.com>
 <CA+6hz4rSg6DSMHNJtrD=GFno08Sj0jb8ezktY-=yH3k5zTVZMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philp Prindeville <philipp@redfish-solutions.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        paulus@samba.org, "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:47921 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcHVJyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 05:54:32 -0400
Content-Disposition: inline
In-Reply-To: <CA+6hz4rSg6DSMHNJtrD=GFno08Sj0jb8ezktY-=yH3k5zTVZMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 08:13:48AM +0800, Feng Gao wrote:
> inline
> 
> On Mon, Aug 22, 2016 at 6:36 AM, Philp Prindeville
> <philipp@redfish-solutions.com> wrote:
> > Inline
> >
> >
> > On 08/20/2016 09:52 AM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
> >>
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> >> 0x03, and 2 separately.
> >>
> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> >> ---
> >>   v3: Modify the subject;
> >>   v2: Only replace the literal number with macros according to Guillaume's
> >> advice
> >>   v1: Inital patch
> >>
> >>   net/l2tp/l2tp_ppp.c | 8 ++++----
> >>   1 file changed, 4 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> >> index d9560aa..65e2fd6 100644
> >> --- a/net/l2tp/l2tp_ppp.c
> >> +++ b/net/l2tp/l2tp_ppp.c
> >> @@ -177,7 +177,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff
> >> *skb)
> >>         if (!pskb_may_pull(skb, 2))
> >>                 return 1;
> >>   -     if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
> >> +       if ((skb->data[0] == PPP_ALLSTATIONS) && (skb->data[1] == PPP_UI))
> >
> >
> > This should have used PPP_ADDRESS() and PPP_CONTROL() here.
> 
> In my initial patch, I replace them with PPP_ADDRESS() and PPP_CONTROL.
> But Guillaume thought it was not clear as before.
> So I revert it.
> 
> >
> >>                 skb_pull(skb, 2);
> >
> >
> > This magic number should go away.
> 
> Same as above.
> 
> >
> >>         return 0;
> >> @@ -282,7 +282,7 @@ static void pppol2tp_session_sock_put(struct
> >> l2tp_session *session)
> >>   static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
> >>                             size_t total_len)
> >>   {
> >> -       static const unsigned char ppph[2] = { 0xff, 0x03 };
> >> +       static const unsigned char ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
> >
> >
> > PPP has a 4-byte header.  Where's the protocol value?
> 
> In the original code, I fail to find the code which is used to fill
> the protocol value.
> So I keep the two bytes header. And I thought the protocol value may be filled
> by the upper layer.
> 
And you were right. This was a macro replacement patch anyway, so you
didn't have to bring functional changes with it.
And if the protocol field was really missing, the L2TP module would
have never worked.
