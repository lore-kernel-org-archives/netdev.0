From: David Miller <davem@davemloft.net>
Subject: Re: TCP minisock tcp_create_openreq_child() typo?
Date: Wed, 28 Feb 2007 11:06:33 -0800 (PST)
Message-ID: <20070228.110633.122616507.davem@davemloft.net>
References: <200702281203.38112@nienna>
	<39e6f6c70702280410k2d13afc7k1f870c73b6862676@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@balabit.hu, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932334AbXB1TGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:06:35 -0500
In-Reply-To: <39e6f6c70702280410k2d13afc7k1f870c73b6862676@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 28 Feb 2007 09:10:10 -0300

> On 2/28/07, KOVACS Krisztian <hidden@balabit.hu> wrote:
> >
> >   Hi,
> >
> >   While reading TCP minisock code I've found this suspiciously looking
> > code fragment:
> >
> > - 8< -
> > struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
> > {
> >         struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
> >
> >         if (newsk != NULL) {
> >                 const struct inet_request_sock *ireq = inet_rsk(req);
> >                 struct tcp_request_sock *treq = tcp_rsk(req);
> >                 struct inet_connection_sock *newicsk = inet_csk(sk);
> >                 struct tcp_sock *newtp;
> > - 8< -
> >
> >   The above code initializes newicsk to inet_csk(sk), isn't that supposed
> > to be inet_csk(newsk)?  As far as I can tell this might leave
> > icsk_ack.last_seg_size zero even if we do have received data.
> 
> Good catch!
> 
> David, please apply the attached patch.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks everyone.
