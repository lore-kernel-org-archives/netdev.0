From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Mon, 14 Mar 2016 10:12:17 -0400
Message-ID: <CAF=yD-Kdh9f+aRDBdpDk8C6Ap4r281O_kwW=S2x+RH8=R7Mmug@mail.gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
 <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com> <69BFB2EA-BADE-420C-93E5-1320D53EB2C0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gilberto Bertin <gilberto.bertin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:32898 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750AbcCNOM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 10:12:58 -0400
Received: by mail-lb0-f173.google.com with SMTP id oe12so3728389lbc.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 07:12:58 -0700 (PDT)
In-Reply-To: <69BFB2EA-BADE-420C-93E5-1320D53EB2C0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - write a bpf filter like this:
..
>
> - compile it:
>         $ clang -target bpf -c -o socket_bpf.o socket_bpf.c
>
> - add this to your server.c:
>         bpf_load_file("/path/to/socket_bpf.o");
>         setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd, sizeof(prog_fd[0]));
>
> - link your server with a couple of libbpf libraries (I'm
>  using the kernel ones from samples/bpf) and -lelf
>
> And this is still simplified (since instead of hardcoding the subnet
> into the bpf filter it would be preferable to use maps).
>
>
> thoughts:
> - SO_BINDTOSUBNET is much simpler to configure than BPF
> - BPF requires some external C libraries and I think it would not be
>  trivial to get it working with other languages than C/C++.

You can easily write BPF by hand.

See for instance attach_ebpf() in tools/testing/selftests/net/reuseport_bpf.c
