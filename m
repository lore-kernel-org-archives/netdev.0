From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Sun, 20 Apr 2008 13:57:42 -0300
Message-ID: <20080420165742.GA12221@ghostprotocols.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804172203.07758.tomasz@grobelny.oswiecenia.net> <20080418101336.GA13526@gerrit.erg.abdn.ac.uk> <200804192242.33632.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164AbYDTQ5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 12:57:49 -0400
Content-Disposition: inline
In-Reply-To: <200804192242.33632.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
> Dnia Friday 18 of April 2008, Gerrit Renker napisa=C5=82:
> > | > There is a more serious problem here: apparently no one tried t=
o
> > | > compile the `qpolicy' subtree since the changes on Monday. It f=
ails
> > | > with the BUILD_BUG_ON.
> > | >
> > | > I tried yesterday evening and found that there is not even a
> > | > possibility of adding a single field to struct dccp_skb_cb: wit=
h the
> > | > addition of the inet{,6}_skb_parm, the struct has reached its m=
aximum
> > | > size of 48 bytes (try printk("%u", sizeof(struct dccp_skb_cb));=
).
> > | >
> > | > There is a solution to this, will post a revised patch shortly.
> > |
> > | What you proposed in the patch should work ok for qpolicies for n=
ow. But
> > | sooner or later the need to add a field to struct dccp_skb_cb wil=
l arise.
> > | So maybe we should think about it now...
> > | Other possibility apart from what you proposed in the patch is cr=
eating
> > | struct dccp_skb_cb_ext, move to it some fields from struct dccp_s=
kb_cb
> > | and in struct add a pointer to this new struct dccp_skb_cb_ext. O=
k, maybe
> > | it is not the prettiest idea but in case somebody needs yet anoth=
er
> > | additional field in struct dccp_skb_cb_ext it would be nice to ha=
ve an
> > | idea how to do it.
> >
> > When the patch failed to compile I thought about those alternatives=
=2E
> > Trying to extend the dccp_skb_cb over and above what is in there wi=
ll be
> > messy, since the IPv4/v6 parameters are required by other subsystem=
s.
> >
> If inet{,6}_skb_parm is used only outside DCCP code then why at all s=
hould it=20
> be placed in struct dccp_skb_cb taking up quite a lot of valuable spa=
ce? Why=20
> not put it directly in struct sk_buff? Especially that it is present =
in=20
> struct udp_skb_cb, struct tcp_skb_cb as well.

Because all this is used in skb->cb[], a scratchpad for protocols to
use, we can go back to what we had before, that is to not reserve use
for inet6?_skb_parm but be sure to zero it before passing it to IP, as
we don't want IP to be confused with things being non zero there. Then
we can use all its space.

- Arnaldo
