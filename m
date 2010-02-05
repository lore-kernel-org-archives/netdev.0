From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed portnumbers
Date: Fri, 5 Feb 2010 18:08:15 +0900
Message-ID: <201002051808.BFJ51557.SLQFtJVMOOFFOH@I-love.SAKURA.ne.jp>
References: <20100203043332.3817.27932.sendpatchset@localhost.localdomain>
	<e2e108261002042311w59ba1372ld9f8fb2f369ca434@mail.gmail.com>
	<4B6BC7E4.5070909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, davem@davemloft.net
To: bvanassche@acm.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6BC7E4.5070909@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang wrote:
> The problem is that there are some existing applications which use
> fixed port number, we don't have chances to change this for them,
> thus making them working is desired, so they want to reserve these
> port for those applications.
> 
> For example, if I have an appliction which uses port 40000, but
> before this application starts, another application gets this port
> number by bind() with port 0 (i.e. chosen by kernel), in this case,
> that application will fail to start. Again, we don't have any chance
> to change the source code of that application.
> 
And there is a utility called "portreserved" (port reserve daemon).
http://fedoraproject.org/wiki/Features/Portreserve

But that utility cannot close the race window between "portreserved stops
reserving local port numbers" and "applications starts using local port
numbers which portreserved was reserving".

Thus, I think people want to have port reservation mechanism inside kernel
(if it has little impact).
