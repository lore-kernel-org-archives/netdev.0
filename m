From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Fri, 25 Apr 2008 17:40:24 -0300
Message-ID: <20080425204024.GA16635@ghostprotocols.net>
References: <20080421131253.GB12221@ghostprotocols.net> <20080422174152.GD6039@gerrit.erg.abdn.ac.uk> <20080422.154212.108914213.davem@davemloft.net> <200804252133.11264.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, gerrit@erg.abdn.ac.uk,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760214AbYDYUkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 16:40:37 -0400
Content-Disposition: inline
In-Reply-To: <200804252133.11264.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Apr 25, 2008 at 09:33:11PM +0200, Tomasz Grobelny escreveu:
> Dnia Wednesday 23 of April 2008, David Miller napisa=C5=82:
> > From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> > Date: Tue, 22 Apr 2008 18:41:52 +0100
> >
> > > | If we iron this out we could finally return to the main subject=
 of this
> > > | thread. That is Patch v2 by me and Gerrit...
> > > | --
> > >
> > > Fully agree - we just need to decide whether or not to use skb->p=
riority.
> > >
> > > Below is as far as I got in integrating your patch last week, it =
shows
> > > only the major changes. The following bits have been updated:
> > >
> > >  * skb->priority now cleared before passing the skb onto layer 3;
> > >  * order of statements in prio_push() reversed (first dropping wo=
rst
> > >    skb and then pushing the new skb - this is better when e.g.
> > >    tx_qlen=3D1);
> > >  * added general parsing routine for cmsg(3) socket control messa=
ges
> > >    and defined one for the SOL_DCCP socket level; thanks to advic=
e
> > >    by Dave Miller
> >
> > If this usage of skb->priority is going to override the
> > IP_TOS socket option setting, I don't think it's a good
> > idea.
> >
> > Right now every packet output goes through ip_output.c
> > which sets skb->priority to sk->sk_priority, which is set
> > by the user via the IP_TOS socket option in ip_sockglue.c
> >=20
> But I guess this assignment happens a bit later (that is after outgoi=
ng packet=20
> leaves DCCP code). Consequently using skb->priority should not harm a=
s it=20
> will be overwritten. Or did I miss something?

I haven't read all the patches, but I guess Tomasz is on the safe side
as the intended skb->priority usage is limited to DCCP, when IP is
handed the skb it can do as it pleases with skb->priority.

- Arnaldo
