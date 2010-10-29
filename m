From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 22:20:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1010292217390.24561@swampdragon.chaosbits.net>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk> <1288380431.2680.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1149779595-1288383612=:24561"
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288380431.2680.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1149779595-1288383612=:24561
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 29 Oct 2010, Eric Dumazet wrote:

> Le vendredi 29 octobre 2010 à 19:18 +0100, Alban Crequy a écrit :
> > Hi,
> > 
> > When a process calls the poll or select, the kernel calls (struct
> > file_operations)->poll on every file descriptor and returns a mask of
> > events which are ready. If the process is only interested by POLLIN
> > events, the mask is still computed for POLLOUT and it can be expensive.
> > For example, on Unix datagram sockets, a process running poll() with
> > POLLIN will wakes-up when the remote end call read(). This is a
> > performance regression introduced when fixing another bug by
> > 3c73419c09a5ef73d56472dbfdade9e311496e9b and
> > ec0d215f9420564fc8286dcf93d2d068bb53a07e.
> > 
> > The attached program illustrates the problem. It compares the
> > performance of sending/receiving data on an Unix datagram socket and
> > select(). When the datagram sockets are not connected, the performance
> > problem is not triggered, but when they are connected it becomes a lot
> > slower. On my computer, I have the following time:
> > 
> > Connected datagram sockets: >4 seconds
> > Non-connected datagram sockets: <1 second
> > 
> > The patch attached in the next email fixes the performance problem: it
> > becomes <1 second for both cases. I am not suggesting the patch for
> > inclusion; I would like to change the prototype of (struct
> > file_operations)->poll instead of adding ->poll2. But there is a lot of
> > poll functions to change (grep tells me 337 functions).
> > 
> > Any opinions?
> 
> My opinion would be to use epoll() for this kind of workload.
> 
Sorry to intrude out of the blue without really understanding the kernel 
side of most of the code in question, but if there's a performance 
regression for applications using poll() shouldn't we address that so we 
get back to the prior performance level rather than requireing all 
userspace apps to switch to epoll() ??

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--8323328-1149779595-1288383612=:24561--
