From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: Get critical word in first 64bit of
 cache line
Date: Sun, 03 Feb 2013 19:11:28 -0800
Message-ID: <1359947488.30177.135.camel@edumazet-glaptop>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	 <1359817435.30177.70.camel@edumazet-glaptop>
	 <20130203.160855.1118626925419072868.davem@davemloft.net>
	 <1359937109.30177.128.camel@edumazet-glaptop>
	 <1359937509.30177.131.camel@edumazet-glaptop>
	 <CAOGi=dO-_MedVNvNy=+VyKXG2D=Mat8=Vyr-CttxcrNFO0Vt5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	maze@google.com
To: Ling Ma <ling.ma.program@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:39498 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab3BDDLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 22:11:31 -0500
Received: by mail-da0-f54.google.com with SMTP id n2so2445983dad.27
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 19:11:31 -0800 (PST)
In-Reply-To: <CAOGi=dO-_MedVNvNy=+VyKXG2D=Mat8=Vyr-CttxcrNFO0Vt5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 10:53 +0800, Ling Ma wrote:
> I attached my test program(we force all cpu loads issue one by one ,
> and avoid cpu hardwre prefetch cc -o test-cwf test-cwf.c.) and
> cpu-info, the result from ./test-cwf  indicates as below:
> looking-up aligned time 157000272, looking-up unaligned time 162652724
> If I was wrong please correct me.

I have no idea why you use assembly code.

unsigned long lookingup_memmory(char *access, int num)
{
        __asm__("sub $1, %rsi");
        __asm__("xor %rax, %rax");
        __asm__("1:");
        __asm__("mov (%rdi), %r8");
        __asm__("add %r8, %rax");
        __asm__("mov %r8, %rdi");
        __asm__("sub $1, %rsi");
        __asm__("jae 1b");
}

Your program is really hard to read.
