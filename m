From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: SSE instructions for fast packet copy?
Date: Mon, 8 May 2017 15:46:21 -0400
Message-ID: <20170508194621.5khsjn7xgdxfggfz@f1.synalogic.ca>
References: <CALx6S34r6Q_wCKqzv5YjKJyuETyYmY1y=M7uDYiLfpnXzqbheg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37682 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753385AbdEHTqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:46:25 -0400
Received: by mail-it0-f47.google.com with SMTP id x188so44041408itb.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 12:46:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34r6Q_wCKqzv5YjKJyuETyYmY1y=M7uDYiLfpnXzqbheg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/05/04 22:50, Tom Herbert wrote:
> Hi,
> 
> I am thinking about the possibility of using SSE in kernel for
> speeding up the kernel memcpy particularly for copy to userspace
> emeory, and maybe even using the string instructions (like if we
> supported regex in something like eBPF). AFAIK we don't use SSE in
> kernel because of xmm register state needing to be saved across
> context switch. However, if we start busy-polling a CPU in kernel on
> network queues then there might not be any context switches to worry
> about. In this model we'd want to enable SSE per CPU.
> 
> Has this ever been tried before? Is this at all feasible? :-) Is it
> possible to enable SSE for kernel for just one CPU? (I found CPUID
> will return SSE supported, but don't see how to enable other than
> -msse for compiling).

This reminds me of what you tried in
	c6e1a0d12ca7 net: Allow no-cache copy from user on transmit
	(v3.0-rc1)
and that I reverted in
	cdb3f4a31b64 net: Do not enable tx-nocache-copy by default
	(v3.14-rc1)

Sure, it's not exactly the same thing...
