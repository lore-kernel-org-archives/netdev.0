From: Andrew Morton <akpm@osdl.org>
Subject: Re: divide error: 0000 in fib6_rule_match [Re: 2.6.18-rc4-mm3]
Date: Mon, 28 Aug 2006 14:30:03 -0700
Message-ID: <20060828143003.aaae0d7d.akpm@osdl.org>
References: <20060826160922.3324a707.akpm@osdl.org>
	<20060828200716.GA4244@inferi.kami.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52684 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932136AbWH1VaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 17:30:13 -0400
To: Mattia Dongili <malattia@linux.it>
In-Reply-To: <20060828200716.GA4244@inferi.kami.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 22:07:16 +0200
Mattia Dongili <malattia@linux.it> wrote:

> [   44.412000]  =======================
> [   44.412000] Code: 00 00 00 89 d8 83 e0 1f 0f 85 9a 00 00 00 8b 5d 08 0f b6 53 68 84 d2 75 78 8b 55 08 8b 5d 0c 8b 4a 60 8b 43 28 31 c8 89 d1 31 d2 <f7> 71 64 85 c0 0f 94 c0 0f b6 c0 8b 5d f4 8b 75 f8 8b 7d fc 89 
> [   44.412000] EIP: [<d1516aca>] fib6_rule_match+0x7a/0x150 [ipv6] SS:ESP 0068:cd9d4d0c
> [   44.412000]  <6>note: sshd[3780] exited with preempt_count 1
> 
> config and full dmesg:
> http://oioio.altervista.org/linux/config-2.6.18-rc4-mm3-1
> http://oioio.altervista.org/linux/dmesg-2.6.18-rc4-mm3-1
> 
> it's at fib6_rules.c:132 but since I can't tell why r->fwmask is 0 I'll
> avoid proposing a wrong patch :)

Oh.  It looks like this has already been fixed:

#ifdef CONFIG_IPV6_ROUTE_FWMARK
        if ((r->fwmark ^ fl->fl6_fwmark) & r->fwmask)
                return 0;
#endif

there's no divide in there now.
