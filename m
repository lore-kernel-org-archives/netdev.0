From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: 05 Apr 2005 08:54:49 -0400
Message-ID: <1112705689.1088.209.camel@jzny.localdomain>
References: <20050405190024.024D.LARK@linux.net.cn>
	 <20050405121605.GM26731@postel.suug.ch>
	 <20050405202039.0250.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050405202039.0250.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-04-05 at 08:39, Wang Jian wrote:
> Hi Thomas Graf,
> 
> 
> On Tue, 5 Apr 2005 14:16:05 +0200, Thomas Graf <tgraf@suug.ch> wrote:
> 
> > 
> > What I'm worried about is that we lose the zero collisions behaviour
> > for the most popular use case.
> 
> If a web interface is used to generate netfilter/tc rules that use
> nfmark, then the above assumption is false. nfmark will be used
> incrementally and wrapped back to 0 somewhere like process id. So zero
> collision is not likely.
> 

Yes, but the distribution is still very good even in that case.
If you have 257 entries then all except for two will be in separate
buckets. 

> When linux's QoS control capability is widely used, such web interface
> sooner or later comes into being.
>  
> > New idea: we make this configureable and allow 3 types of hash functions:
> >  1) default as-is, perfect for marks 0..255
> >  2) all bits taken into account (your patch)
> >  3) bitmask + shift provided by the user just like
> >     dsmark.
> > 
> > Thoughts?
> 
> Your suggestion is very considerable. But that needs some more work. And,
> isn't that some bloated?
> 

Why dont you run a quick test? Very easy to do in user space.
Enter two sets of values using the two different approaches; yours and 
the current way tc uses nfmark (incremental). And then apply the jenkins
approach you had to see how well it looks like? I thinkw e know how it
will look with current hash - but if you can show its not so bad in the
case of jenkins as well it may be an acceptable approach,

cheers,
jamal
