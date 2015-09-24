From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: ss: improve horizontal output scaling
Date: Thu, 24 Sep 2015 05:25:47 -0700
Message-ID: <1443097547.29850.159.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150924111650.GY24212@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33148 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbbIXMZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 08:25:53 -0400
Received: by pacex6 with SMTP id ex6so72043441pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 05:25:52 -0700 (PDT)
In-Reply-To: <20150924111650.GY24212@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-24 at 13:16 +0200, Phil Sutter wrote:
> Hi,
> 
> Currently, ss scales it's output to the available horizontal screen
> space available, so that the regular columns (Netid, State, Recv-Q,
> Send-Q, Local Address:Port and Peer Address:Port) use the maximum space
> available and extended information (e.g. users) get wrapped into a new
> line.
> 
> While this approach is sufficient for smaller terminals to improve
> readability, it's kind of awkward in full-screen terminals which provide
> enough space to display everything on the same line.
> 
> On the other hand, the current approach makes sense in that the output
> width is hard to predict: Unix domain sockets have a filesystem path as
> local address, which might be really long (e.g. 68 characters for a
> libvirt socket on my box). The '-p' flag prints process names, so
> extended information might become very long as well. The actual width of
> each line's fields is not known before it has been printed. Since input
> potentially comes from netlink, there is no random access which could be
> used to scroll quickly through the input and find each column's longest
> field.
> 
> There are a number of possible ways to improve this:
> 
> 1. Introduce scalemax parameter:
>    This parameter specifies the maximum terminal width to scale to.
>    Implementation is trivial, and works well for me as my terminals are
>    either 95, 126 or 193 characters wide. Setting scalemax to 128 leaves
>    line wrapping in place in all but full-screen mode. Though other's
>    mileage may vary, and fiddling with this number is inconvenient as
>    well.

The big ss mistake was to not insert a new line before 'extended' info
(this gives uid: ino: and sk: fields)

"ss -te | more" only gives one line per socket today

But "ss -ti" gives 2 lines per socket

Not sure we can change this. Maybe make it conditional to
 if (isatty(STDOUT_FILENO)) 

(If stdout is a terminal, then cap the screen_width to 100 but insert a
new line before extended)

I very often use "ss -tei|more" to get rid of these extra long lines, so
I would vote to cap screen_width to 100 anyway.
