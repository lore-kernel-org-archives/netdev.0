From: Simon Horman <horms@verge.net.au>
Subject: Re: RFC:  Allow 'ip' to run in daemon mode?
Date: Thu, 1 Jul 2010 16:07:53 +0900
Message-ID: <20100701070753.GA15216@verge.net.au>
References: <4C2A1291.7000203@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:42950 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab0GAHHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 03:07:55 -0400
Content-Disposition: inline
In-Reply-To: <4C2A1291.7000203@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 08:34:41AM -0700, Ben Greear wrote:
> I'm considering modifying 'ip' to be able to run in daemon
> mode so that I can do lots of IP commands without having to
> pay the startup cost of iproute.
> 
> The -batch option almost works, but it's hard to programatically
> figure out failure codes.
> 
> I'm thinking about making these changes:
> 
> 1)  Move all of the error printing code into common methods (basically,
>    wrap printf).  In daemon mode this text can be sent back to the
>    calling process, and in normal mode, it will be printed to stdout/stderr
>    as it is currently.
> 
> 2)  Remove all or most calls to 'exit' and instead return error codes
>    to the calling logic.
> 
> 3)  Add ability to listen on a unix socket for commands, basically treat
>    them just like batch commands, one command per packet.
> 
> 4)  Return well formatted error code and text response to calling process
>    over the unix socket, maybe something like:
> 
> RV: [errno or equiv, zero for success]\n
> CMD: [ command string this relates to ]\n
> [ Optional free form text ]
> 
> 
> Does something like this have any chance of upstream inclusion?

Hi Ben,

can't you achieve as much by omitting 3) and using stdio (cleanly)?
Or in other words, fix batch mode rather than adding another mode.
Or are you worried about backwards-compatibility?

