From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Linux 2.6.0-test9
Date: Tue, 28 Oct 2003 01:42:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F9DBB7F.7030309@tpack.net>
References: <200310271936.WAA07348@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, akpm@osdl.org, Andries.Brouwer@cwi.nl,
        Kernel Mailing List
 <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, "David S. Miller"
 <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>And Alexey apparently tried to do the "FIXME" part, but without thinking 
>>about the SIGURG part.
> 
> 
> Actually, it was thought a lot for several linux-2.x. :-)
> 
> 
> 
>>We _need_ to stop at urgent data and we _should_ return -EINTR, and let
>>the SIGURG handler do the URG read. Otherwise we'll lose urgent data (or
>>we'll just read it inline without realizing that it was urgent data).
> 
> 
> The patch was expected not to break this property. Alas, something
> is overlooked yet. I still do not understand what exactly is broken,
> I feel I have to find some rlogin to experiment in vivo.

Hi Alexey

I think the patch breaks things because it consumes (or rather skips)
the urgent data ( in the code after the label found_ok_skb: ).

Since this happens before the SIGURG handler is run, it won't find
any urgent data.

What do you think?

The patch by Linus seems to be fine though.

-Tommy
