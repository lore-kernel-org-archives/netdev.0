From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 12:05:09 -0700
Message-ID: <20150430190508.GA13037@Alexeis-MBP.westell.com>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
 <20150430011633.GA12674@Alexeis-MBP.westell.com>
 <20150430101204.GA3167@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34965 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbbD3TFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 15:05:14 -0400
Content-Disposition: inline
In-Reply-To: <20150430101204.GA3167@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 12:12:04PM +0200, Pablo Neira Ayuso wrote:
> 
> These are the numbers I got banging *one single CPU*:
> 
> * Without patches + qdisc ingress:
> 
> Result: OK: 16298126(c16298125+d0) usec, 10000000 (60byte,0frags)
>   613567pps 294Mb/sec (294512160bps) errors: 10000000
> 
> * With patches + qdisc ingress on top of hooks:
> 
> Result: OK: 18339281(c18339280+d0) usec, 10000000 (60byte,0frags)
>   545277pps 261Mb/sec (261732960bps) errors: 10000000
> 
> * With patches + nftables ingress chain:
> 
> Result: OK: 17118167(c17118167+d0) usec, 10000000 (60byte,0frags)
> 
>   584174pps 280Mb/sec (280403520bps) errors: 10000000

So in other words you're saying: tc has to live with 12%
slowdown (613k / 545k) only because _you_ want one hook
for both nft and tc ?!

The numbers from my box are 22.4 Mpps vs 18 Mpps which is 24%
slowdown for TC due to nf_hook.
Notice I'm seeing _millions_ packet per second processed by
netif_receive_skb->ingress_qdisc->u32
whereas you're talking about _thousands_.
Even if your box is very old, it still doesn't explain this
huge difference.
Please post 'perf report' numbers, so we can help analyze
what is actually being measured. I bet netif_receive_skb
is not even in top 10.
