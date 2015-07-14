From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked by
 higher protocol
Date: Tue, 14 Jul 2015 13:59:49 +0200
Message-ID: <20150714115949.GE25674@breakpoint.cc>
References: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
 <20150714110501.GC25674@breakpoint.cc>
 <3167EFAB95044A4EB6B134B9A39AA98A055B5E50@xmb-rcd-x05.cisco.com>
 <20150714113531.GD25674@breakpoint.cc>
 <3167EFAB95044A4EB6B134B9A39AA98A055B60A2@xmb-rcd-x05.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49275 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751882AbbGNL7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:59:51 -0400
Content-Disposition: inline
In-Reply-To: <3167EFAB95044A4EB6B134B9A39AA98A055B60A2@xmb-rcd-x05.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yigal Reiss (yreiss) <yreiss@cisco.com> wrote:
> Florian Westphal [mailto:fw@strlen.de] wrote:
> > Maybe, but if you broute everything you might as well just remove the
> > bridge...
> I want to be selective. My setup is a home router. So I can have ebtables rules for 
> which traffic to (b)route and which to bridge, based on security/performance criteria.

This usually doesn't work since you can only safely use L3 headers
(unless you disallow ip fragmentation to occur -- else first fragment
 will be brouted, rest is bridged).

> > You can use -j redirect in ebtables broute table to force local MAC dnat
> > (this also 'fixes' the pkttype to _HOST) if you really want to broute.
> I may be missing something obvious, but what is the normal case where using an 
> ebtables 'broute' "-j DROP" rule does work?

It doesn't, (for ip protocols), as you discovered.
But there are other protocols too, so I'm not sure its good idea to
uncoditionally reset pkttype.

(It also changes long-standing behaviour).

Note that broute only "works" in some cases, such as brouting a specific
host.

'Sometimes bridged, sometimes routed' usually causes various issues,
such as ip addresses seemingly 'moving' to different host.

> What is the original intention of this table/chain if not pulling packets between 
> "other hosts" out of the bridge and passing them through the IP and higher layers?

No idea, I did not add this feature.
