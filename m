From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4 2/2] net: sctp: rework debugging framework
 to use pr_debug and friends
Date: Fri, 28 Jun 2013 15:44:04 -0700
Message-ID: <1372459444.29380.33.camel@joe-AO722>
References: <1372441780-9844-1-git-send-email-dborkman@redhat.com>
	 <1372441780-9844-3-git-send-email-dborkman@redhat.com>
	 <1372458077.29380.30.camel@joe-AO722> <51CE10DE.20006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60570 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752415Ab3F1WoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 18:44:05 -0400
In-Reply-To: <51CE10DE.20006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 00:40 +0200, Daniel Borkmann wrote:
> On 06/29/2013 12:21 AM, Joe Perches wrote:
> > On Fri, 2013-06-28 at 19:49 +0200, Daniel Borkmann wrote:
> >
> >> @@ -536,11 +540,8 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
> >>   	struct list_head	*pos;
> >>   	struct sctp_transport	*transport;
> >>
> >> -	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_rm_peer:association %p addr: ",
> >> -				 " port: %d\n",
> >> -				 asoc,
> >> -				 (&peer->ipaddr),
> >> -				 ntohs(peer->ipaddr.v4.sin_port));
> >> +	pr_debug("%s: association:%p addr:%pISpc\n",
> >> +		 __func__, asoc, &peer->ipaddr.sa);
> >
> > Hi again Daniel.
> >
> > Perhaps the format is better written as "%pIScp"
> > with the port after the compression as that's how
> > the actual output would be produced.
> 
> Actually it really doesn't matter. One could also argue that this way it's
> from generic to specific ... i.e. "%pISp" is the generic part as it's valid
> for both IPv4/IPv6, and "c" is a IPv6-specific appendix.

<shrug>  I read left to right.  The ipv6 bit comes first.
Also, I'm not demanding, just suggesting.

> >> @@ -636,12 +637,8 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
> > []
> >> +	pr_debug("%s: association:%p addr:%pISpc state:%d\n", __func__,
> >> +		 asoc, &addr->sa, peer_state);
> >
> > etc...
> >
> >> +		pr_debug("%s: sending window update SACK- asoc:%p rwnd:%u "
> >> +			 "a_rwnd:%u\n", __func__, asoc, asoc->rwnd,
> >
> > Please coalesce formats. It doesn't matter if
> > the coalesced format exceeds 80 cols.
[]
> Hm, as this is something cosmetic, really really minor and does not concern
> all pr_debugs, are you okay if I "fix" some of them (where appropriate) as
> a follow-up? Thanks !

'course.

Please do run your patches through checkpatch though.
