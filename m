From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 23:56:27 +0100
Message-ID: <20080201225627.GB3071@ami.dom.local>
References: <1201867609.4465.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:43716 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756700AbYBAWw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:52:59 -0500
Received: by ug-out-1314.google.com with SMTP id z38so829312ugc.16
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:52:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1201867609.4465.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote, On 02/01/2008 01:06 PM:

> On Fri, 2008-01-02 at 10:56 +0100, Patrick McHardy wrote:
> 
>> We don't want to disable TSO for cases where it makes sense, but
>> who is using TBF on 10GbE? The point is that most users of qdiscs
>> which are incapable of dealing with TSO without hacks or special
>> configuration probably don't care, and 10GbE users know about
>> ethtool *and* don't use TBF or HTB (which are probably the only
>> qdiscs which actually have problems, maybe also CBQ).
> 
> Right - Essentially it is a usability issue:
> People who know how to use TSO (Peter for example) will be clueful
> enough to turn it on. Which means the default should be to protect the
> clueless and turn it off.
> On Andis approach:
> Turning TSO off at netdev registration time with a warning will be a
> cleaner IMO. Or alternatively introducing a kernel-config "I know what
> TSO is" option which is then used at netdev registration. From a
> usability perspective it would make more sense to just keep ethtool as
> the only way to configure TSO. 
> 
> [I recently spent a few days helping someone debug a problem with IFB
> because he was redirecting packets from an TSO netdevice and occasionaly
> some multi-packet will be missed in the calculation; my answer was "turn
> off TSO"; so there are more use cases for this TSO issue]. 

I totally disagree with these POVs:

- 10G cards should be treated by default as 10G cards - not DSL modems,
  and common users shouldn't have to read any warnings or configs to
  see this.
- tc with TBF or HTB are professional tools; there should be added some
  warnings to manuals. But trying to change the way they work because
  we think we know better what users want, and changing BTW some other
  things (making debugging this later a hell), is simply disrespectful
  for target users of these tools. There are some wrappers or "creators"
  invented for this. And, BTW, I think I've seen somewhere a system
  which does this this other way - with creators for professionals. So,
  you could be right with this too...

Cheers,
Jarek P.
