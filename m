From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Sun, 20 Apr 2008 22:12:12 +0200
Message-ID: <200804202212.12283.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804192242.33632.tomasz@grobelny.oswiecenia.net> <20080420165742.GA12221@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4090 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451AbYDTUM7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 16:12:59 -0400
In-Reply-To: <20080420165742.GA12221@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Sunday 20 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
> > > When the patch failed to compile I thought about those alternativ=
es.
> > > Trying to extend the dccp_skb_cb over and above what is in there =
will
> > > be messy, since the IPv4/v6 parameters are required by other
> > > subsystems.
> >
> > If inet{,6}_skb_parm is used only outside DCCP code then why at all
> > should it be placed in struct dccp_skb_cb taking up quite a lot of
> > valuable space? Why not put it directly in struct sk_buff? Especial=
ly
> > that it is present in struct udp_skb_cb, struct tcp_skb_cb as well.
>
> Because all this is used in skb->cb[], a scratchpad for protocols to
> use, we can go back to what we had before, that is to not reserve use
> for inet6?_skb_parm but be sure to zero it before passing it to IP, a=
s
> we don't want IP to be confused with things being non zero there. The=
n
> we can use all its space.
>
Several questions regarding this case:
1. What about SCTP? It doesn't have inet6?_skb_parm in it's structure t=
hat is=20
stored in skb->cb. So does it contain a potential bug (that is to be fi=
xed)=20
or is it not needed there or what?
2. If the sole purpose of this change was to keep skb->cb zeroed then i=
t=20
doesn't seem to me like the right solution. Wasting about 20 bytes inst=
ead of=20
zeroing them when needed I would consider at least weird. I understand =
that=20
TCP and UDP may have enough space left but it just turned out that DCCP=
=20
doesn't.
3. If it's IP layer that needs zeroes then why not clear skb->cb in IP =
layer?
--=20
Regards,
Tomasz Grobelny
