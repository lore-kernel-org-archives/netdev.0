From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Wed, 6 Apr 2005 11:15:09 -0700
Message-ID: <20050406111509.0462abcf.davem@davemloft.net>
References: <20050405213023.0256.LARK@linux.net.cn>
	<1112717495.1076.22.camel@jzny.localdomain>
	<20050406143842.026B.LARK@linux.net.cn>
	<20050406123036.GO26731@postel.suug.ch>
	<1112794459.1096.61.camel@jzny.localdomain>
	<20050406134502.GP26731@postel.suug.ch>
	<20050406141020.GQ26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, lark@linux.net.cn, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050406141020.GQ26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Apr 2005 16:10:20 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> The thing I'm worrying about is that I don't want to break the perfect
> alignment of fw_head to good slab obj sizes but I guess there is no
> way around. I'd really like to make hash size and hash function
> configureable. For example a hash size of 1024 would perform much
> better and would still fit into a single page on most systems.

I think a hash xor'ing in the high bits into the low 8 bits, as has
been suggested a few times already, meets your criteria and solves
Lark's problem.

The hash table size, if still an issue, can be dynamically sized based
upon some criteria with some reasonable default initial selection
(such as the current 256).

I think dynamic hash function selection is madness.  You have a key
that needs to be hashed, you are aware of one very common usage
(the one that perfectly hashes currently) and you are also aware of
a method by which the cases that don't fit into that mold can be made
to perform acceptably too (xor'ing in the upper bits).  We can thus
do this with one single hash function.
