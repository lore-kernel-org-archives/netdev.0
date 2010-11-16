From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Tue, 16 Nov 2010 23:13:10 +0100
Message-ID: <20101116221310.GA3058@nuttenaction>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
 <20101110.102129.112602843.davem@davemloft.net>
 <1289414024.2469.20.camel@edumazet-laptop>
 <20101110.103807.39173013.davem@davemloft.net>
 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	drosenberg@vsecurity.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:58045 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932772Ab0KPWWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 17:22:12 -0500
Content-Disposition: inline
In-Reply-To: <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tetsuo Handa | 2010-11-16 22:08:50 [+0900]:

>--- a/net/core/filter.c
>+++ b/net/core/filter.c
>@@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
>  */
> int sk_chk_filter(struct sock_filter *filter, int flen)
> {
>-	struct sock_filter *ftest;
>+	/*
>+	 * Valid instructions are initialized to non-0.
>+	 * Invalid instructions are initialized to 0.
>+	 */
>+	static u16 codes[] = {
>+		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K + 1,
>+		[BPF_ALU|BPF_ADD|BPF_X]  = BPF_S_ALU_ADD_X + 1,
>+		[BPF_ALU|BPF_SUB|BPF_K]  = BPF_S_ALU_SUB_K + 1,
[...]

Maybe I don't get it, but you increment the opcode by one, but you never
increment the opcode in sk_run_filter() - do I miss something? Did you test
the your patch (a trivial tcpdump rule should be sufficient)?

If this question is answered (or fixed):

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

HGN
