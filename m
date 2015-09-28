From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [net] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 28 Sep 2015 16:51:36 -0700
Message-ID: <CALnjE+q0=W2VzCKBqWXeWtfTFBgZUG5-RgvxcgeKXpCSSjT3kg@mail.gmail.com>
References: <20150928094525.GA770@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: 1441061746-1492-1-git-send-email-pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38233 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbbI1Xvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 19:51:36 -0400
Received: by igxx6 with SMTP id x6so61932249igx.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 16:51:36 -0700 (PDT)
In-Reply-To: <20150928094525.GA770@odin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 2:46 AM, Andrew Vagin <avagin@odin.com> wrote:
> Hi,
>
> With this patch, I can't connect two local tcp ipv6 sockets.
>
> [root@fc22-vm criu]# strace -e network python ipv6.py
> socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
> bind(3, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
> listen(3, 1)                            = 0
> socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 4
> connect(4, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 ETIMEDOUT (Connection timed out)
>
> [root@fc22-vm criu]# cat ipv6.py
> import socket
>
> srv = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
> srv.bind(("::0", 8976))
> srv.listen(1)
> c = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
> c.connect(("::1", 8976))
>

Thanks for the bug report. I am working on fix. I will send it out soon.
