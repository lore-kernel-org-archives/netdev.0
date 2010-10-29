From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 13:46:15 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk> <1288380431.2680.3.camel@edumazet-laptop> <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-744411154-1288384889=:8517"
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-744411154-1288384889=:8517
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Fri, 29 Oct 2010, Davide Libenzi wrote:

> On Fri, 29 Oct 2010, Eric Dumazet wrote:
> 
> > Le vendredi 29 octobre 2010 à 19:18 +0100, Alban Crequy a écrit :
> > > Hi,
> > > 
> > > When a process calls the poll or select, the kernel calls (struct
> > > file_operations)->poll on every file descriptor and returns a mask of
> > > events which are ready. If the process is only interested by POLLIN
> > > events, the mask is still computed for POLLOUT and it can be expensive.
> > > For example, on Unix datagram sockets, a process running poll() with
> > > POLLIN will wakes-up when the remote end call read(). This is a
> > > performance regression introduced when fixing another bug by
> > > 3c73419c09a5ef73d56472dbfdade9e311496e9b and
> > > ec0d215f9420564fc8286dcf93d2d068bb53a07e.
> > > 
> > > The attached program illustrates the problem. It compares the
> > > performance of sending/receiving data on an Unix datagram socket and
> > > select(). When the datagram sockets are not connected, the performance
> > > problem is not triggered, but when they are connected it becomes a lot
> > > slower. On my computer, I have the following time:
> > > 
> > > Connected datagram sockets: >4 seconds
> > > Non-connected datagram sockets: <1 second
> > > 
> > > The patch attached in the next email fixes the performance problem: it
> > > becomes <1 second for both cases. I am not suggesting the patch for
> > > inclusion; I would like to change the prototype of (struct
> > > file_operations)->poll instead of adding ->poll2. But there is a lot of
> > > poll functions to change (grep tells me 337 functions).
> > > 
> > > Any opinions?
> > 
> > My opinion would be to use epoll() for this kind of workload.
> 
> Yeah, epoll does check for event hints coming with the callback wakeup, 
> and avoid waking up epoll_wait() waiters, for non matching events.

Also, why not using the existing wait->key instead of adding a poll2()?


- Davide

--8323329-744411154-1288384889=:8517--
