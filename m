From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Thu, 05 May 2005 19:02:26 +0200
Message-ID: <427A51A2.8090600@eurodev.net>
References: <20050504234036.GH18452@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504234036.GH18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas,

Thomas Graf wrote:
> The patch is separated into 3 parts, the first one being the textsearch
> infrastructure itself followed by a simple Knuth-Morris-Pratt
> implementation for reference. I'm also working on what could be called
> the smallest regular expression implementation ever but I left that
> out for now since it still has issues. Last but not least the
> function skb_find_text() written in a hurry and probably not yet
> correct but you should get the idea. From a userspace perspective
> the first user will be an ematch but writing it will be peanuts
> so I left it out for now.
> 
> Basically what it looks like right now is:
> 
> int pos;
> struct ts_state;
> struct ts_config *conf = textsearch_prepare("kmp", "hanky", 5, GFP_KERNEL, 1);
> 
> /* search for "hanky" at offset 20 until end of packet */
> for (pos = skb_find_text(skb, 20, INT_MAX, conf, &state;
>      pos >= 0;
>      pos = textsearch_next(conf, &state)) {
>         printk("Need a hanky? I found one at offset %d.\n", pos);
> }
> 
> textsearch_put(conf);
> kfree(conf);

I haven't got too much time to review this stuff in deep though. 
Impressive work, but I still miss something, some comments:

- A custom destroy function in ts_ops.
- I don't see a way to look for matches in fragments. I mean, say we've 
got "dancing " in a fragment and "chicken" in the next one. Currently we 
don't get a match.
- I particularly like Rusty's skb iterator, well you've refactored that 
code anyway.

I've been reworking the framework for string matching that I sent you 
two/three months ago, you've definitely worked on a good base. Since 
then I've introduced a lot of changes and actually I've been testing it 
(ick, that means that we've clashed!).

I think that I can merge both works and then roll on. I still need more 
time to study more in deep your proposition.

--
Pablo
