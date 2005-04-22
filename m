From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Fri, 22 Apr 2005 13:11:00 +0200
Message-ID: <20050422111100.GN577@postel.suug.ch>
References: <20050419012147.038F.LARK@linux.net.cn> <20050418184029.GV4114@postel.suug.ch> <20050422115230.03E0.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050422115230.03E0.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I understand all of your arguments but I would like to, if possible,
> > avoid to add yet another quite specific qdisc which could have been
> > implemented in a generic way for everyone to use. Your FRG basically
> > does what the alloctor + classifier + action + qdiscs can do but it
> > is orientied at one specific use case.
> 
> Agree. I will maintain my code out of kernel tree, in case someone feels
> my frg is usefull for his/her special case.

Definitely, I think your work is very valuable and if the generic
approach doesn't work out I'll be all for including your work. Well,
maybe move the flow id generation into an action but leave the class
allocation in frg. 

> The other disadvantage is that the dynamic classid used is not predicted
> by user space, it is very tricky for user space to handle the classid
> allocation then (I mean for the management system like web management).
> That is what I try to avoid so far.

Good point, we can make the handle of the allocated classes/qdiscs
be derived from the flow id we get and additionaly broadcast any
change in the qdisc/class management to userspace for it to keep
track. Let me develop some more thoughts on this and get back to you.

> I agree to this. But I must iterate one thing: the design should be
> friendly to user space management for a heavy usage.

Agreed.

I had another look at your code and noticed the GFP_KERNEL masked
kmalloc call in perflow_new_flow() called from perflow_enqueue(),
you must change that to GFP_ATOMIC due to softirq context.
