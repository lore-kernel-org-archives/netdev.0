From: Joe Perches <joe@perches.com>
Subject: Re: oh crap... (re: %p6)
Date: Wed, 29 Oct 2008 08:39:19 -0700
Message-ID: <1225294760.5269.301.camel@localhost>
References: <20081029.015402.234525839.davem@davemloft.net>
	 <1225292124.20276.12.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4284 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbYJ2PjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 11:39:25 -0400
In-Reply-To: <1225292124.20276.12.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 07:55 -0700, Harvey Harrison wrote:
> On Wed, 2008-10-29 at 01:54 -0700, David Miller wrote:
> > I think we'll need to revert all of this or find some fix soon.  GCC
> > warns about %p with a '#' flag modifier it seems :-(
> > 
> > net/ipv6/ip6_flowlabel.c: In function 'ip6fl_seq_show':
> > net/ipv6/ip6_flowlabel.c:707: warning: '#' flag used with '%p' printf format
> 
> The easiest would be to pick a separate modifier for the raw case.  Or
> revert the removal of NIP6_SEQFMT, I'll shoot you a patch shortly,
> any preference in what modifier should be used?

I'd prefer something visual that represents "no colon".

Maybe %p6-: 

Or perhaps slightly worse to change the colon separated 
default %p6 to %p:6

There are another cases where the v6 address should have
as few leading zeros as possible or where the interior
zeros should be collapsed using :: separators.

Perhaps a good solution is to use the equivalent of
a "display-hint" after the %p6

Maybe use combinations of:

%p6:: use "::" and collapse when 0
%p6-: raw hex
%p6-0 %x not %04x
%p6.4 last u32 as ipv4 dotted decimal



