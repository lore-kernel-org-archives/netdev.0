From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Bug-hunting
Date: Wed, 23 Feb 2005 00:21:31 +0100
Message-ID: <421BBE7B.1050009@rapidforum.com>
References: <421B4AB7.9030003@rapidforum.com>	<20050222104448.31373a99.davem@davemloft.net>	<421B8563.9030608@rapidforum.com> <20050222115114.0d0e568e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050222115114.0d0e568e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hm can you tell me how to change the limit? It seems the limit is good for 3/1 systems but not for 
2/2 systems.

To reproduce this, you would have to create a server which is sending data to 4000 non-blocking 
sockets. It doesnt matter what you send. You should realize a slow-down the more sockets you use. 
You need Gigabit for this to appear.

David S. Miller wrote:
> On Tue, 22 Feb 2005 20:17:55 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>No. This is a new thing and this wasnt there before. In 2.6.10-rc2 the kernel aborted programs with 
>>"Out of memory" when too many buffers are allocated and low memory was full. NOW it just shrinks the 
>>buffers dynamically. I don't want that. I have a 2/2 system and I want 1600 MB for buffers but you 
>>only allow around 700 MB for buffers. This is definetly NEW.
> 
> 
> It always shrinks the TCP socket buffer usage when the total socket
> memory used by TCP is over the threshold.  This code has been there
> for 3 years at least.
> 
> If the behavior has changed, that's interesting and probably due to
> some other change.  It could even be a MM layer change that is causing
> things to behave differently now for you, and because things are
> being tweaked in the memory management all the time (particularly
> the handling of lowmem vs. highmem) this would not surprise me at
> all.
> 
> But the basic framework for shrinking socket buffers when total TCP
> memory usage crosses some threshold has been there and has been
> enabled for a long time.
> 
> Anyways, we're stalled on figuring out exactly what is wrong due to
> lack of information and difficulty in reproducing.  The ball is still
> in your court.
> 
> Why don't you put together a very simple test case that others can
> use to analyze and reproduce your bug?  I bet we'll fix it or figure
> out what is wrong with your app within 24 hours once you do that. :-)
> 
> 
