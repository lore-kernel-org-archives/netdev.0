From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFC:  Allow 'ip' to run in daemon mode?
Date: Thu, 1 Jul 2010 09:35:27 -0700
Message-ID: <20100701093527.37b7d828@nehalam>
References: <4C2A1291.7000203@candelatech.com>
	<20100701070753.GA15216@verge.net.au>
	<4C2CB739.3020001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39637 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806Ab0GAQf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 12:35:29 -0400
In-Reply-To: <4C2CB739.3020001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Jul 2010 08:41:45 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 07/01/2010 12:07 AM, Simon Horman wrote:
> > On Tue, Jun 29, 2010 at 08:34:41AM -0700, Ben Greear wrote:
> >> I'm considering modifying 'ip' to be able to run in daemon
> >> mode so that I can do lots of IP commands without having to
> >> pay the startup cost of iproute.
> >>
> >> The -batch option almost works, but it's hard to programatically
> >> figure out failure codes.
> >>
> >> I'm thinking about making these changes:
> >>
> >> 1)  Move all of the error printing code into common methods (basically,
> >>     wrap printf).  In daemon mode this text can be sent back to the
> >>     calling process, and in normal mode, it will be printed to stdout/stderr
> >>     as it is currently.
> >>
> >> 2)  Remove all or most calls to 'exit' and instead return error codes
> >>     to the calling logic.
> >>
> >> 3)  Add ability to listen on a unix socket for commands, basically treat
> >>     them just like batch commands, one command per packet.
> >>
> >> 4)  Return well formatted error code and text response to calling process
> >>     over the unix socket, maybe something like:
> >>
> >> RV: [errno or equiv, zero for success]\n
> >> CMD: [ command string this relates to ]\n
> >> [ Optional free form text ]
> >>
> >>
> >> Does something like this have any chance of upstream inclusion?
> >
> > Hi Ben,
> >
> > can't you achieve as much by omitting 3) and using stdio (cleanly)?
> > Or in other words, fix batch mode rather than adding another mode.
> > Or are you worried about backwards-compatibility?
> 
> I think the most of the work will be in steps 1 and 2.  Adding a listening
> socket and dealing with that is probably 50-100 lines of code.
> 
> I'd be happy to attempt steps 1, 2, and possibly 4 for standard iproute2.
> If the unix socket thing still isn't wanted, it would be relatively easy for me
> to carry a patch to enable it in my own code.
> 
> I think a lot of folks are scraping the output of 'ip', so backwards compat of
> the error messages is a concern.

Use libnl and write a real service. Maybe even use json


-- 
