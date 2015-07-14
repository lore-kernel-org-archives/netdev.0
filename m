From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked by
 higher protocol
Date: Tue, 14 Jul 2015 13:35:31 +0200
Message-ID: <20150714113531.GD25674@breakpoint.cc>
References: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
 <20150714110501.GC25674@breakpoint.cc>
 <3167EFAB95044A4EB6B134B9A39AA98A055B5E50@xmb-rcd-x05.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49094 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750835AbbGNLfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:35:32 -0400
Content-Disposition: inline
In-Reply-To: <3167EFAB95044A4EB6B134B9A39AA98A055B5E50@xmb-rcd-x05.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yigal Reiss (yreiss) <yreiss@cisco.com> wrote:
> > No, thats not the problem you're trying to solve.
> > 
> > If you want to move OTHERHOST skbs, don't (b)route them?
> > 
> > Whats the real issue that you're trying to solve?
> 
> I want to (b)route them because I want to be able to inspect the packets in higher levels
> (through iptables or user space IPS).

For nfqueue via iptables, use call-iptables sysctl?

Alternatively, implement NFQUEUE support for NF_BRIDGE family,
we'll need this eventually for nftables bridge family anyway.

AF_PACKET should just 'work' without brouting.

> Once I do that (i.e. (b)route by applying an appropriate ebtables rule), the corresponding
> packets get dropped unless I apply the patch.

Maybe, but if you broute everything you might as well just remove the
bridge...

You can use -j redirect in ebtables broute table to force local MAC dnat (this also
'fixes' the pkttype to _HOST) if you really want to broute.
