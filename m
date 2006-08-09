From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: Stackable devices.
Date: Wed, 9 Aug 2006 15:57:09 +0200
Message-ID: <200608091557.09249.Christophe.Devriese@eurid.eu>
References: <44CA34D0.1070507@candelatech.com> <20060808120307.GA17547@walrus.eth1.org> <44D8BD99.1090505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:36283 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S1750834AbWHIN5O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 09:57:14 -0400
Received: from localhost (smtp.eurid.eu [127.0.0.1])
	by smtp.eurid.eu (Postfix) with ESMTP id B570D1252C4
	for <netdev@vger.kernel.org>; Wed,  9 Aug 2006 15:57:13 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <44D8BD99.1090505@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It would however be considerable effort to do this. Is this going to end up 
unapplied like my last patch, or ?

Regards,

Christophe

On Tuesday 08 August 2006 18:36, you wrote:
> Christophe Devriese wrote:
> > On Wed, Aug 02, 2006 at 10:50:08AM -0700, Ben Greear wrote:
> >>Currently, the bridge hook logic is something like:
> >>
> >>if (bridge-consumed-pkt) {
> >>	return
> >>}
> >>
> >>// drop through to other layers
> >>
> >>
> >>There are several other hooks I'd like to see added (pktgen receive
> >>processing,
> >>mac-vlans, etc).  Each of these hooks are logically similar to the bridge
> >>hook,
> >>ie if it consumes the pkt, return, else, drop through to the next hook
> >>untill
> >>we get to the regular protocol processing logic.
> >>
> >>I would like to be able to chain layer-2 handlers, such as bridge,
> >> mac-vlan, pktgen such that if one consumed, you break out of the
> >> handling, else, you try the next handler.  The handlers can be
> >> dynamically registered and inserted
> >>in any order, controllable by user-space and/or module load/unload.
> >>
> >>For many of the handlers, the logic will re-insert the packet by
> >> re-calling the
> >>netif-rx logic, so there would need to be some protection to keep loops
> >> from occurring that would recurse too much and overflow the stack.
> >
> > I'm also a big fan of a generalized system like this. It would need to
> > catch both the vlan accelerated path and the normal path.
>
> Well, it isn't actually needed for VLANs since VLAN's hook is a protocol
> handler....
>
> Ben
