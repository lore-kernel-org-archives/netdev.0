From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: Dynamically classifying flows?
Date: Mon, 7 Mar 2005 18:10:43 -0600
Message-ID: <7bca1cb505030716104856fe3@mail.gmail.com>
References: <7bca1cb505030709502316f9b8@mail.gmail.com>
	 <20050307203450.GX31837@postel.suug.ch>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050307203450.GX31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> It is a likely scenario but usually not a problem because you can classify this
> kind of bulk packets by their size. u32 can be used use for such things or the
> newly added meta ematch.
Filtering by size may not always work. An interactive flow may also
generate big (MTU) size packets, but it is interactive because the
_rate_ at which packets are produced is smaller. Though, if you think
that such cases are purely theoretical and don't create problems in
practice, do let me know.

> > Question 2: Does the idea of _dynamically_ classifying traffic as interactive
> > or bulk make any sense at all? Or does the TOS field work well enough for
> > dynamic classification to not be of any practical interest?
> 
> Yes it does and that's exactly the direction the ematch API is going to.
Can you point me to some details on ematch? Specifically, how it
supports dynamic  classifications of flows? Seems like this is
something really new you guys are working on, so not much
documentation is available.

> > Can we use ideas from process scheduling to be kinder to the interactive
> > flows? 
> In order to prioritize there must be a queue, and for remote terminal protocols
> you want to avoid queues at any cost because it will introduce latency in any
> case. Even on overloaded lines with full queues, the queues are rarely bigh
> enough to really apply any sort of priority queues.
Won't we always have queues? After all a qdisc essentially specifies a
de-queuing algorithm. I was thinking along the lines of process
scheduling to be able to avoid having to manually specify flow
priorities. Ideally speaking, it would automatically classify remote
terminal flows such that they see the least possible queueing delays.
Though, you seem to be of the opinion that manual classification is
easy enough and most traffic worth worrying about use DSCP flags
effectively. Is that correct?

Thanks for your comments,
Regards,

-- Asim
