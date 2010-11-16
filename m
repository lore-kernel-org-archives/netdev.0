From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 00:45:05 +0100
Message-ID: <20101116234505.GC3058@nuttenaction>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
 <20101110.102129.112602843.davem@davemloft.net>
 <1289414024.2469.20.camel@edumazet-laptop>
 <20101110.103807.39173013.davem@davemloft.net>
 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
 <20101116221310.GA3058@nuttenaction>
 <AANLkTi=-Kr7OpSSz1aTQxTEwaOwf_m6hPDr24vYw_z75@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	davem@davemloft.net, eric.dumazet@gmail.com,
	drosenberg@vsecurity.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:51341 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753121Ab0KPXpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 18:45:07 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=-Kr7OpSSz1aTQxTEwaOwf_m6hPDr24vYw_z75@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Changli Gao | 2010-11-17 07:31:51 [+0800]:

>> Maybe I don't get it, but you increment the opcode by one, but you never
>> increment the opcode in sk_run_filter() - do I miss something? Did you test
>> the your patch (a trivial tcpdump rule should be sufficient)?
>>
>
>+               code = codes[code];
>+               if (!code--)
>+                       return -EINVAL;

Right, temporary in sk_chk_filter() but as I wrote earlier not in sk_run_filter().

>But how about this:
>
>enum {
>        BPF_S_RET_K = 1,

better.

Best regards, Hagen

BTW: you can verify your code by construct some artificial filter rules via

struct sock_filter {
	uint16_t  code;   /* Actual filter code */
	uint8_t   jt;     /* Jump true */
	uint8_t   jf;     /* Jump false */
	uint32_t  k;      /* Generic multiuse field
};

and attach them to a socket with setsockopt.
