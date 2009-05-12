From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 22:59:12 +0200
Message-ID: <20090512205912.GA3263@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <20090512192748.GA2757@ami.dom.local> <4A09D1B4.7070509@cosmosbay.com> <20090512200515.GB2757@ami.dom.local> <4A09E18B.3020402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:38269 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbZELVA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:00:58 -0400
Received: by fxm2 with SMTP id 2so236204fxm.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 14:00:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A09E18B.3020402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2009 at 10:52:27PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Tue, May 12, 2009 at 09:44:52PM +0200, Eric Dumazet wrote:
> >> Jarek Poplawski a =E9crit :
> >>> On Tue, May 12, 2009 at 10:21:12AM +0200, Eric Dumazet wrote:
> >>>> Eric Dumazet a =E9crit :
> >>> ...
> >>>>> List of devices that must clear this flag is :
> >>>>>
> >>>>> - loopback device, because it calls netif_rx() and quoting Patr=
ick :
> >>>>>     "ip_route_input() doesn't accept loopback addresses, so loo=
pback packets
> >>>>>      already need to have a dst_entry attached."
> >>>>> - appletalk/ipddp.c : needs skb->dst in its xmit function
> >>>>>
> >>>>> - And all devices that call again dev_queue_xmit() from their x=
mit function
> >>>>> (as some classifiers need skb->dst) : bonding, macvlan, eql, if=
b, hdlc_fr
> >>> Why not vlan (and/or maybe others in net/ using dev_queue_xmit)?
> >>>
> >> Yes I spoted vlan earlier this afternoon.
> >>
> >> For other net/*, I didnt not find candidates yet.
> >=20
> > Hmm..., if vlan, then why not pppoe (and/or maybe others in drivers=
/net/
> > using dev_queue_xmit)?
> >=20
>=20
> As I said, I didnt found other relevant uses, but I am probably wrong=
 :)
>=20
> About ppoe for example, two calls to dev_queue_xmit() are not relevan=
t.
>=20
> One is from=20
>=20
> static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
>           struct msghdr *m, size_t total_len)
>=20
> This is a normal direct call, not a call from its ndo_start_xmit()
>=20
> Second one is from
>=20
> static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
>=20
> Same observation, there is no impact for this one as well.
>=20
>=20
>=20
> So we have to care on device drivers that have a ndo_start_xmit() cal=
l that could
> re-enter dev_queue_xmit(). Not care about drivers that call dev_queue=
_xmit() from
> other paths.
>=20

Isn't it called through ppp_generic's ndo_start_xmit()?

Jarek P.
