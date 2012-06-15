From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC] Introduce to batch variants of accept() and epoll_ctl() syscall
Date: Fri, 15 Jun 2012 09:35:29 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F4D@saturn3.aculab.com>
References: <4FDAB652.6070201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<davidel@xmailserver.org>
To: "Li Yu" <raise.sail@gmail.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4FDAB652.6070201@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
>   We encounter a performance problem in a large scale computer
> cluster, which needs to handle a lot of incoming concurrent TCP
> connection requests.
> 
>   The top shows the kernel is most cpu hog, the testing is simple,
> just a accept() -> epoll_ctl(ADD) loop, the ratio of cpu util sys% to
> si% is about 2:5.
> 
>   I also asked some experienced webserver/proxy developers in my team
> for suggestions, it seem that behavior of many userland 
> programs already
> called accept() multiple times after it is waked up by
> epoll_wait(). And the common action is adding the fd that accept()
> return into epoll interface by epoll_ctl() syscall then.
> 
>   Therefore, I think that we'd better to introduce to batch 
> variants of
> accept() and epoll_ctl() syscall, just like sendmmsg() or recvmmsg().
...

Having seen the support added to NetBSD for sendmmsg() and
recvmmsg() (and I'm told the linux code is much the same),
I'm surprised that just cutting out a system call entry/exit
and fd lookup is significant above the rest of the costs
involved in sending a message (which I presume is UDP here).
I'd be even more surprised if it is significant for an
incoming connection.

	David
