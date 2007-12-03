From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process's securitycontext.
Date: Mon, 3 Dec 2007 22:17:00 +0900
Message-ID: <200712032217.IDF40534.FFOJQMHtVOOSFL@I-love.SAKURA.ne.jp>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
	<200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
	<Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<4753B743.2090501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net, linux-security-module@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: kaber@trash.net, jmorris@namei.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4753B743.2090501@trash.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Patrick McHardy wrote:
> No news on that. I'm also a bit sceptical if adding all this complexity
> and overhead would really be worth it (considering only netfilter) just
> to use the owner match and UID/GID matching. It wouldn't even be
> accurate because there is not 1:1 mapping of sockets and processes.
Considering only LSM, socket_post_accept()/socket_post_recv_datagram() hooks are
not complicated at all.
A socket may be mapped to multiple processes, but at the moment of picking up
(i.e. accept()/recvmsg()), I think it is accurate 1:1 mapping.
I'm more interested in "Who picks this connection/datagram up?" than
"Which socket enqueues this connection/datagram?"
It may be indifferent for netfilter, but it is region of interest for me.

> I actually like Samir Bellabes' approach, which doesn't suffer from
> these problems IIRC.
Oh, I found him at http://nfws.inl.fr/en/?p=50 . (Sorry, I didn't know.)
He is the person who was discussing with me a few days ago.

> >>From memory, one approach under discussion was to add netfilter hooks to 
> > the transport layer, which could be invoked correctly by each type of 
> > protocol when the target process is selected.
> 
> We can only invoke the hooks after the socket lookup, but we don't
> know which process is going to call recvmsg() for that socket.

Right. Thus, I'm proposing LSM hooks at accept()/recvmsg() time.

Regards.
