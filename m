From: "David S. Miller" <davem@davemloft.net>
Subject: Re: "dst cache overflow"
Date: Tue, 21 Sep 2004 15:24:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921152411.72b4092e.davem@davemloft.net>
References: <16719.13095.369830.547715@robur.slu.se>
	<20040921215501.GE3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, cd@cdaniel.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040921215501.GE3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 23:55:02 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> I bet that something inside the kernel forgets dst_release().. IMQ is
> just compiled, not used (so I don't see how it should come from this).
> 
> Any comments, suggestions?

Most likely it is a leak like that, yes.

Here is my suggstion for debugging this:

1) Boot with profile=2 or similar.
2) Disable the platform code that bumps the profiling
   counters at the timer interrupt.
3) Make every piece of which gets or puts a dst entry
   reference pass it's PC to some function which
   increments the profile buffer entry.  (use
   current_text_addr())

Then after running for some time use readprofile to figure
out what subsystem or area is causing the references.
