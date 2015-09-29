From: Andrey Vagin <avagin@odin.com>
Subject: Re: [net] skbuff: Fix skb checksum flag on skb pull
Date: Tue, 29 Sep 2015 10:30:44 +0300
Message-ID: <20150929073043.GA29815@odin.com>
References: <20150928094525.GA770@odin.com>
 <CALnjE+o1==Z7NA2JzyfcKUuPGqjKU9rLsy20e7Gi8njo4-Ye-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([199.115.105.18]:57758 "EHLO
	mx2.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbbI2Hay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 03:30:54 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+o1==Z7NA2JzyfcKUuPGqjKU9rLsy20e7Gi8njo4-Ye-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 03:27:03AM +0300, Pravin Shelar wrote:
> On Mon, Sep 28, 2015 at 2:46 AM, Andrew Vagin <avagin@odin.com> wrote:
> > Hi,
> >
> > With this patch, I can't connect two local tcp ipv6 sockets.
> >
> > [root@fc22-vm criu]# strace -e network python ipv6.py
> > socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
> > bind(3, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
> > listen(3, 1)                            = 0
> > socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 4
> > connect(4, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 ETIMEDOUT (Connection timed out)
> >
> > [root@fc22-vm criu]# cat ipv6.py
> > import socket
> >
> > srv = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
> > srv.bind(("::0", 8976))
> > srv.listen(1)
> > c = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
> > c.connect(("::1", 8976))
> >
> 
> Can you try following patch.
> https://patchwork.ozlabs.org/patch/523632/

It works for me. Thanks.
