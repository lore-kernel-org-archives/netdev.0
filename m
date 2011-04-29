From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 6/6] Update documentation for -u/-U operations
Date: Fri, 29 Apr 2011 03:57:42 +0100
Message-ID: <1304045862.3105.6.camel@localhost>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204045.23054.12548.stgit@gitlad.jf.intel.com>
	 <1303928629.2875.91.camel@bwh-desktop>  <4DB9D0D9.2000401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13439 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758391Ab1D2C5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 22:57:50 -0400
In-Reply-To: <4DB9D0D9.2000401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-28 at 13:40 -0700, Alexander Duyck wrote:
> On 4/27/2011 11:23 AM, Ben Hutchings wrote:
> > On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
[...]
> >> --- a/ethtool.8.in
> >> +++ b/ethtool.8.in
> >> @@ -42,10 +42,20 @@
> >>   [\\fB\\$1\\fP\ \\fIN\\fP]
> >>   ..
> >>   .\"
> >> +.\"	.BM - same as above but has a mask field for format "[value N [value-mask N]]"
> >> +.\"
> >> +.de BM
> >> +[\\fB\\$1\\fP\ \\fIN\\fP\ [\\fB\\$1\-mask\\fP\ \\fIN\\fP]]
> >
> > You've changed the code to accept 'm' as an alternative to
> > <field>  '-mask', so this should be changed accordingly.
> 
> What would be the preferred way of stating that?  For now I just 
> replaced the \\$1\-mask with m.  However I am assuming that probably 
> isn't the best approach either.  Should I state somewhere that m can be 
> replaced with "field name"-mask?

I think that's reasonable.

[...]
> >> +.BN class-rule-del
> >> +.RB [\  flow-type \ \*(NC
> >> +.RB [ src \ \*(MA\ [ src-mask \ \*(MA]]
> >> +.RB [ dst \ \*(MA\ [ dst-mask \ \*(MA]]
> >> +.BM proto
> >> +.RB [ src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]]
> >> +.RB [ dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]]
> >> +.BM tos
> >> +.BM l4proto
> >> +.BM src-port
> >> +.BM dst-port
> >> +.BM spi
> >> +.BM vlan-etype
> >> +.BM vlan
> >> +.BM user-def
> >> +.BN action
> >> +.BN loc
> >> +.RB ]
> >
> > But these options aren't all applicable to all flow-types.
> 
> This is the part that gets messy and I am not sure what the best 
> approach is.  I have more comments on that below.  For now what I am 
> planning to implement to address this is that in the "DESCRIPTION" 
> section below I add a statement to each specifier that has restrictions 
> by stating "Valid for flow-types X, Y, and Z."

OK.

> > [...]
> >> diff --git a/ethtool.c b/ethtool.c
> >> index 421fe20..e65979d 100644
> >> --- a/ethtool.c
> >> +++ b/ethtool.c
> >> @@ -243,20 +243,26 @@ static struct option {
> >>   		"		equal N | weight W0 W1 ...\n" },
> >>       { "-U", "--config-ntuple", MODE_SCLSRULE, "Configure Rx ntuple filters "
> >>   		"and actions",
> >> -		"		{ flow-type tcp4|udp4|sctp4\n"
> >> -		"		  [ src-ip ADDR [src-ip-mask MASK] ]\n"
> >> -		"		  [ dst-ip ADDR [dst-ip-mask MASK] ]\n"
> >> -		"		  [ src-port PORT [src-port-mask MASK] ]\n"
> >> -		"		  [ dst-port PORT [dst-port-mask MASK] ]\n"
> >> -		"		| flow-type ether\n"
> >> -		"		  [ src MAC-ADDR [src-mask MASK] ]\n"
> >> -		"		  [ dst MAC-ADDR [dst-mask MASK] ]\n"
> >> -		"		  [ proto N [proto-mask MASK] ] }\n"
> >> -		"		[ vlan VLAN-TAG [vlan-mask MASK] ]\n"
> >> -		"		[ user-def DATA [user-def-mask MASK] ]\n"
> >> -		"		action N\n" },
> >> +		"		[ class-rule-del %d ] |\n"
> >> +		"		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
> >> +		"			[ src %x:%x:%x:%x:%x:%x [src-mask %x:%x:%x:%x:%x:%x] ]\n"
> >> +		"			[ dst %x:%x:%x:%x:%x:%x [dst-mask %x:%x:%x:%x:%x:%x] ]\n"
> >> +		"			[ proto %d [proto-mask MASK] ]\n"
> >> +		"			[ src-ip %d.%d.%d.%d [src-ip-mask %d.%d.%d.%d] ]\n"
> >> +		"			[ dst-ip %d.%d.%d.%d [dst-ip-mask %d.%d.%d.%d] ]\n"
> >> +		"			[ tos %d [tos-mask %x] ]\n"
> >> +		"			[ l4proto %d [l4proto-mask MASK] ]\n"
> >> +		"			[ src-port %d [src-port-mask %x] ]\n"
> >> +		"			[ dst-port %d [dst-port-mask %x] ]\n"
> >> +		"			[ spi %d [spi-mask %x] ]\n"
> >> +		"			[ vlan-etype %x [vlan-etype-mask %x] ]\n"
> >> +		"			[ vlan %x [vlan-mask %x] ]\n"
> >> +		"			[ user-def %x [user-def-mask %x] ]\n"
> >> +		"			[ action %d ]\n"
> >> +		"			[ loc %d]]\n" },
> > [...]
> >
> > Again, it's not clear which options apply to which flow-types, and the
> > 'm' shortcut is not documented.
> 
> The 'm' part I agree with 100%, however the flow types are going to 
> become kinda hairy using that approach.  You basically end up with 
> something like this:
[...]

Yes, I see the problem.

> As you can see it will be a bit oversized to go through and specify 
> which flow-type options support what fields.  If that is what you want I 
> can implement it that way but for now I would prefer calling out the 
> flow-type limitations of the fields in the "DESCRIPTION" portion of the 
> man page.

In fact, even with this patch, the help for -U is pretty oversized.  It
might be better to replace the list of field names with '...' here and
only list them in full in the man page.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

