From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2] net, cls: allow for deleting all filters for
 given parent
Date: Fri, 10 Jun 2016 17:31:20 -0700
Message-ID: <20160611003117.GA87076@ast-mbp.thefacebook.com>
References: <4f60a899712d32c9c635107b4278a1b62cd18f3e.1465591897.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35895 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcFKAbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 20:31:25 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so27801805pfb.3
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 17:31:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4f60a899712d32c9c635107b4278a1b62cd18f3e.1465591897.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 11:10:22PM +0200, Daniel Borkmann wrote:
> Add a possibility where the user can just specify the parent and
> all filters under that parent are then being purged. Currently,
> for example for scripting, one needs to specify pref/prio to have
> a well-defined number for 'tc filter del' command for addressing
> the previously created instance or additionally filter handle in
> case of priorities being the same. Improve usage by allowing the
> option for tc to specify the parent and removing the whole chain
> for that given parent.
> 
> Example usage after patch, no tc changes required:
> 
>   # tc qdisc replace dev foo clsact
>   # tc filter add dev foo egress bpf da obj ./bpf.o
>   # tc filter add dev foo egress bpf da obj ./bpf.o
>   # tc filter show dev foo egress
>   filter protocol all pref 49151 bpf
>   filter protocol all pref 49151 bpf handle 0x1 bpf.o:[classifier] direct-action
>   filter protocol all pref 49152 bpf
>   filter protocol all pref 49152 bpf handle 0x1 bpf.o:[classifier] direct-action
>   # tc filter del dev foo egress
>   # tc filter show dev foo egress
>   #

useful feature. thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
