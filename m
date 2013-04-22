From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: you must fix this
Date: Mon, 22 Apr 2013 14:30:26 -0700
Message-ID: <CALnjE+r2DojykXaYC13MUJ9YxeiJwC0OnfS6rtPJU4uLwbO5nw@mail.gmail.com>
References: <20130422.162301.2219305973270706624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:46300 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752630Ab3DVVa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 17:30:27 -0400
Received: by mail-qc0-f199.google.com with SMTP id p7so10727387qcq.2
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 14:30:26 -0700 (PDT)
In-Reply-To: <20130422.162301.2219305973270706624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 1:23 PM, David Miller <davem@davemloft.net> wrote:
>
> You CANNOT call into functional ipv6 functions from unrelated
> kernel modules:
>
> net/built-in.o: In function `ip_tunnel_xmit':
> /home/davem/src/GIT/net-next/net/ipv4/ip_tunnel.c:619: undefined reference to `icmpv6_send'
>
This code is moved from ip_gre module to ip_tunnel in the restructuring
patch. So this dependency is carried from ip_gre module to ip_tunnel module.

> There is no way I can allow this, it requires a call into IPV6 proper
> to a function that cannot be added to one of the source files we
> force building statically into the kernel such as addrconf_core.c
>
> Right now things are completely broken with IPV6=y and everything
> else modular, and that is not acceptable.
>
> DO NOT fix this by adding Kconfig dependencies, and DO NOT fix this
> by mucking with ugly ifdefs the ip_tunnel.c
>
> You have to remove this need to call into a stateful portion of
> the IPV6 code, portions which cannot be moved into simply helper
> functions which get statically linked into the kernel.

ok. I will send fix for ip_tunnel.

Thanks.
