From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 05:43:10 -0500
Message-ID: <50CDA5BE.2080800@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:52282 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab2LPKnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 05:43:13 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so4588489iay.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 02:43:13 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-15 07:59 PM, Jan Engelhardt wrote:
>

> For the C level, there is XTABLES_VERSION_CODE.
>
> #if XTABLES_VERSION_CODE >= 6
> 	if (m != NULL && m->x6_parse != NULL)
> 		m->x6_parse(...)
> #else
> 	else if (m != NULL && m->parse != NULL)
> 		m->parse(...)
> 	...
>

I think you are suggesting this to be done in tc. That would make it 
easier to fix.
IMO, it is easier to keep backward compat if you left the old
APIs around for a period of time and maybe log a warning that they
will be deprecated over a period of time (sort of like kernel approach 
to changing APIs).

BTW: another interface that seems to have changed that we
need is m->final_check().

cheers,
jamal

> We can also export this through pkgconfig, similar to how
> downstream users are to discover the plugin dir
> (`pkg-config xtables --variable libdir`).
>
