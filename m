From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Fri, 25 Apr 2008 21:33:11 +0200
Message-ID: <200804252133.11264.tomasz@grobelny.oswiecenia.net>
References: <20080421131253.GB12221@ghostprotocols.net> <20080422174152.GD6039@gerrit.erg.abdn.ac.uk> <20080422.154212.108914213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4715 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953AbYDYTd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 15:33:26 -0400
In-Reply-To: <20080422.154212.108914213.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Wednesday 23 of April 2008, David Miller napisa=B3:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Tue, 22 Apr 2008 18:41:52 +0100
>
> > | If we iron this out we could finally return to the main subject o=
f this
> > | thread. That is Patch v2 by me and Gerrit...
> > | --
> >
> > Fully agree - we just need to decide whether or not to use skb->pri=
ority.
> >
> > Below is as far as I got in integrating your patch last week, it sh=
ows
> > only the major changes. The following bits have been updated:
> >
> >  * skb->priority now cleared before passing the skb onto layer 3;
> >  * order of statements in prio_push() reversed (first dropping wors=
t
> >    skb and then pushing the new skb - this is better when e.g.
> >    tx_qlen=3D1);
> >  * added general parsing routine for cmsg(3) socket control message=
s
> >    and defined one for the SOL_DCCP socket level; thanks to advice
> >    by Dave Miller
>
> If this usage of skb->priority is going to override the
> IP_TOS socket option setting, I don't think it's a good
> idea.
>
> Right now every packet output goes through ip_output.c
> which sets skb->priority to sk->sk_priority, which is set
> by the user via the IP_TOS socket option in ip_sockglue.c
>=20
But I guess this assignment happens a bit later (that is after outgoing=
 packet=20
leaves DCCP code). Consequently using skb->priority should not harm as =
it=20
will be overwritten. Or did I miss something?
--=20
Regards,
Tomasz Grobelny
