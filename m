From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 5 Apr 2005 14:52:37 +0200
Message-ID: <20050405125237.GN26731@postel.suug.ch>
References: <20050405190024.024D.LARK@linux.net.cn> <20050405121605.GM26731@postel.suug.ch> <20050405202039.0250.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050405202039.0250.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050405202039.0250.LARK@linux.net.cn> 2005-04-05 20:39
> On Tue, 5 Apr 2005 14:16:05 +0200, Thomas Graf <tgraf@suug.ch> wrote:
> > What I'm worried about is that we lose the zero collisions behaviour
> > for the most popular use case.
> 
> If a web interface is used to generate netfilter/tc rules that use
> nfmark, then the above assumption is false. nfmark will be used
> incrementally and wrapped back to 0 somewhere like process id. So zero
> collision is not likely.

I did not claim that the above assumption is true for all case but the
most common use of cls_fw is static marks set by netfilter to values
from 0..255. 

> When linux's QoS control capability is widely used, such web interface
> sooner or later comes into being.

That might be true but I will never ack on something that makes zero
collision use of cls_fw impossible. I'm all for improving this but
not at the cost of reduced performance for the most obvious use case
of cls_fw.

> Your suggestion is very considerable. But that needs some more work. And,
> isn't that some bloated?

The shift + bitmask might be bloated and can be deferred a bit until
someone comes up with this need. I can cook up a patch for this
if you want, it's not much work.
