From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Bug-hunting
Date: Tue, 22 Feb 2005 11:51:14 -0800
Message-ID: <20050222115114.0d0e568e.davem@davemloft.net>
References: <421B4AB7.9030003@rapidforum.com>
	<20050222104448.31373a99.davem@davemloft.net>
	<421B8563.9030608@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421B8563.9030608@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Feb 2005 20:17:55 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> No. This is a new thing and this wasnt there before. In 2.6.10-rc2 the kernel aborted programs with 
> "Out of memory" when too many buffers are allocated and low memory was full. NOW it just shrinks the 
> buffers dynamically. I don't want that. I have a 2/2 system and I want 1600 MB for buffers but you 
> only allow around 700 MB for buffers. This is definetly NEW.

It always shrinks the TCP socket buffer usage when the total socket
memory used by TCP is over the threshold.  This code has been there
for 3 years at least.

If the behavior has changed, that's interesting and probably due to
some other change.  It could even be a MM layer change that is causing
things to behave differently now for you, and because things are
being tweaked in the memory management all the time (particularly
the handling of lowmem vs. highmem) this would not surprise me at
all.

But the basic framework for shrinking socket buffers when total TCP
memory usage crosses some threshold has been there and has been
enabled for a long time.

Anyways, we're stalled on figuring out exactly what is wrong due to
lack of information and difficulty in reproducing.  The ball is still
in your court.

Why don't you put together a very simple test case that others can
use to analyze and reproduce your bug?  I bet we'll fix it or figure
out what is wrong with your app within 24 hours once you do that. :-)
