From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v3 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Mon, 22 Aug 2016 13:46:49 +0200
Message-ID: <20160822114649.6zzeq4ef4svh4hrt@alphalink.fr>
References: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
 <20160822100716.ixxxppc7x4nce5yx@alphalink.fr>
 <CA+6hz4qoHeQ+eD9j21dZS0KQ8_1cnAkj7j0X4msZaGTBDC3ezQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com>, paulus@samba.org,
        "David S. Miller" <davem@davemloft.net>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55769 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcHVLqx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:46:53 -0400
Content-Disposition: inline
In-Reply-To: <CA+6hz4qoHeQ+eD9j21dZS0KQ8_1cnAkj7j0X4msZaGTBDC3ezQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 06:22:42PM +0800, Feng Gao wrote:
> inline
> 
> On Mon, Aug 22, 2016 at 6:07 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Sat, Aug 20, 2016 at 11:52:27PM +0800, fgao@ikuai8.com wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >> @@ -282,7 +282,7 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
> >>  static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
> >>                           size_t total_len)
> >>  {
> >> -     static const unsigned char ppph[2] = { 0xff, 0x03 };
> >> +     static const unsigned char ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
> >>
> > Minor nit: I'd prefer to keep the space after '{' and before '}'.
> > I didn't want to bother you with this, but since it seems you'll have
> > to repost...
> 
> I don't know if it is the coding style of Linux kernel.
>
Both forms are used currently and I can't recall any explicit
preference statement. So unless David has an opinion, you can just use
the form you like the best.

> > BTW, I thought you also wanted to remove the static ppph variable
> > from pppol2tp_xmit() / pppol2tp_sendmsg(), to directly assign
> > skb->data[0/1] with PPP_ALLSTATIONS/PPP_UI.
> 
> If removed static ppph, there will be some codes which use literal "2"
> instead of sizeof ppph.
> Is it ok?
> 
The literal "2" would be used in the sock_wmalloc() call only (or for
assigning the headroom variable in the case of pppol2tp_xmit()). Given
the number of data summed, I agree that having a plain "2" in the
middle could look odd. You can either add a comment for each data summed
(like in pppol2tp_xmit()), something like:
sock_wmalloc(sk, NET_SKB_PAD +
	     sizeof(struct iphdr) + /* IP header */
	     ...
	     2 +                    /* PPP Address and control field */
	     ...);

Or use a simple macro like:
/* Size of the PPP address and control fields */
#define PPP_ACF_LEN 2

Or event use macro and comment. That's up to you.
You can even drop this change entirely if you prefer, I don't mind.
I just raised this point because you said you'd remove ppph.
