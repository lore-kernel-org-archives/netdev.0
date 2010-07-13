From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute, batch-cmds, and mac-vlans.
Date: Tue, 13 Jul 2010 08:41:23 -0700
Message-ID: <20100713084123.0009b8da@nehalam>
References: <4C3BF050.7040206@candelatech.com>
	<20100712221958.2a87b0e3@nehalam>
	<4C3BFA85.8070500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55366 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab0GMPlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jul 2010 11:41:25 -0400
In-Reply-To: <4C3BFA85.8070500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jul 2010 22:32:53 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 07/12/2010 10:19 PM, Stephen Hemminger wrote:
> > On Mon, 12 Jul 2010 21:49:20 -0700
> > Ben Greear<greearb@candelatech.com>  wrote:
> >
> >> After too much time debugging, I finally realized that the ip
> >> tool was truncating my command because the mac-vlan device name
> >> had a '#' in it.
> >>
> >> ]# cat /tmp/foo.txt
> >> ru add to 10.99.21.1 iif eth0#0 lookup local pref 11
> >>
> >>
> >> # IP tool has some hacked up debugging code
> >> ]# ip -batch /tmp/foo.txt
> >>    argc: 4
> >>    arg -:to:-
> >>    arg -:iif:-
> >> WARNING:  Using TABLE_MAIN in iprule_modify, table_ok: 0  cmd: 32
> >>
> >>
> >> So, it acts on eth0 instead of eth0#0, and silently ignores the 'lookup local pref 11'.
> >>
> >> I understand that it is trying to parse # as comments, but would you
> >> all be interested in a patch that allowed ignoring '#' except
> >> when it is the first non-whitespace character on a line, and maybe
> >> when preceded by whitespace?  This would of course have the possibility
> >> of breaking someone's script somewhere, so it could be enabled with
> >> a new command line arg, perhaps.
> >
> > Putting # in device name just sounds like a bad idea.
> 
> It's been the standard naming for mac-vlans since we started supporting them.
> 
> In case you change your mind, this patch seems to work..though I can't figure out
> how to trigger the second bit of code in the while loop, so it may not be right.
> 
> I'll move my iproute2 tree to github in case someone else wants to give
> it a try.

I am going to put a more restrictive version of getcmdline().  Comments
will only be allowed at start of line.
