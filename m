From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Tue, 26 May 2015 07:35:22 -0700
Message-ID: <1432650922.4060.236.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35578 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbbEZOfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:35:25 -0400
Received: by iesa3 with SMTP id a3so93476097ies.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 07:35:24 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 13:40 +0000, David Laight wrote:

> If the JIT compiler is only changing the encoding of the constants
> in the x86 instructions (rather than changing the instructions themselves)
> then there is likely to me an unmeasurable change in the execution time.
> For instance I don't remember there being a difference in execution time
> between long and short branches - the only difference is the amount of
> cache they use.

icache is precisely the matter here. In the end, it makes a difference.

You could check this interesting study Ingo did recently :

https://lkml.org/lkml/2015/5/19/1009
