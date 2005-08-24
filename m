From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Wed, 24 Aug 2005 09:06:06 -0700
Message-ID: <20050824160606.GC7078@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 24, 2005 at 04:59:32PM +0200, Robert Olsson wrote:

> You could probably also try to set hash table very large.
> via the boot option rt_hash_entries.

I have, and it just grows until it uses up all memory and kills my SSH
session.

> and gc_thresh to 1/4 of that as an experiment.

The threshold appears to have no difference except for where it settles
once I stop the DoS traffic.

> Also if you find any 2.6 version that work a la 2.4 it's 
> a good start.

It's weird because 2.6.11 is a lot better in that the GC appears to work
for some time, but it eventually something happens and it also hits
max_size and overflows continually.  I think I'm going to have to find a
version that works consistently as opposed to being "a little better".

I was just testing it again and noticed that on 2.6.11 it seems to be
almost stable at 71,000 entries (max_size = 131072) but as soon as I type
"dmesg" in another SSH window it will hit 131072.  It's as if it's at
equilibrium with the packet creation.

It may just be as simple as something that has always been buggy but
doesn't show up in 2.4 because the e1000 driver is more efficient there
(and/or some other piece of networking, which appears to be more likely).

Simon-
