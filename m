From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error
 path
Date: Sun, 13 Oct 2013 09:36:34 -0700
Message-ID: <1381682194.3392.42.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381249910-17338-2-git-send-email-murzin.v@gmail.com>
	 <1381676065-2373-1-git-send-email-murzin.v@gmail.com>
	 <1381676065-2373-2-git-send-email-murzin.v@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	av1474@comtv.ru
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:34064 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab3JMQgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 12:36:35 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so6355648pbc.37
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 09:36:35 -0700 (PDT)
In-Reply-To: <1381676065-2373-2-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-13 at 16:54 +0200, Vladimir Murzin wrote:
> Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
> were not passed. At the same time handlers for "any offset" cases make
> the same checks against r_addr at run-time, that will always lead to
> bpf_error.
> 
> Run-time checks are still necessary for indirect load operations, but
> error path for absolute and mesh loads are worth to optimize during bpf
> compile time.

I don't get the point.

What real world use case or problem are you trying to handle ?

bpf_error returns 0, so it seems your patch does the same.

A buggy BPF program should not expect us to 'save' a few cycles.
