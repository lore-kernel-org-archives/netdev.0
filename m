From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 5 Apr 2005 14:16:05 +0200
Message-ID: <20050405121605.GM26731@postel.suug.ch>
References: <20050405140342.024A.LARK@linux.net.cn> <20050405103827.GL26731@postel.suug.ch> <20050405190024.024D.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050405190024.024D.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050405190024.024D.LARK@linux.net.cn> 2005-04-05 19:25
> If you read the thread I pointed to, then you know there is chance that
> nfmark is used as two 16 bit numbers (along with CONNMARK), and the 16
> bit number can be mapped to a classid. This is one of many chances.
> 
> In that case, nfmark can be used like this
> 
> 0x00010000
> 0x00020000
> 0x00030000
> ...
> 
> 0x00000001
> 0x00000002
> 0x00000003
> ...
> 
> The old hash function doesn't expect such pattern.

I'm aware of the problem you're facing, if the lower 8bits are
set to 0 for a large amount of flows you get all that flows
chained in the first hash bucket.

> I must admit that I am not very familiar with hash function. I find that
> and use a quick hack. My patch just points out the existing risk. Anyone
> can improve this by using a faster and even distributed hash function.

I can't really give you feedback on this since I don't have the
background for this. Theoretically a hash size being a prime would
do better but is stupid regarding slab efficiency.

What I'm worried about is that we lose the zero collisions behaviour
for the most popular use case.

New idea: we make this configureable and allow 3 types of hash functions:
 1) default as-is, perfect for marks 0..255
 2) all bits taken into account (your patch)
 3) bitmask + shift provided by the user just like
    dsmark.

Thoughts?
