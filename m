From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Thu, 31 Aug 2006 17:12:43 +0200
Message-ID: <20060831151243.GJ3590@ripe.net>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:48280 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S932102AbWHaPMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 11:12:47 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060829082828.GA8625@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Again,

It took a while to find equipment for test environment, but now I
have a test environment that I can test.

Here is the result:

---------------------------------------------------------------------------
[17180051.768000] ip6_fragment: hlen = 0x818, len = 0x7ce, nexthdr=4
[17180051.840000] ------------[ cut here ]------------
[17180051.840000] kernel BUG at net/ipv6/ip6_output.c:510!
[17180051.840000] invalid opcode: 0000 [#1]
[17180051.840000] SMP 
[17180051.840000] Modules linked in: ipmi_si ipmi_msghandler ide_cd cdrom
[17180051.840000] CPU:    0
[17180051.840000] EIP:    0060:[<c02bc6bd>]    Not tainted VLI
[17180051.840000] EFLAGS: 00010296   (2.6.17.11-ns-pri-debug-p1 #6) 
[17180051.840000] EIP is at ip6_fragment+0x7f6/0x803
[17180051.840000] eax: 00000048   ebx: f75c4c5c   ecx: c038f5bc   edx: 00000286
[17180051.840000] esi: f7605c50   edi: 00000000   ebp: f76e2c80   esp: f7605bb8
[17180051.840000] ds: 007b   es: 007b   ss: 0068
[17180051.840000] Process named (pid: 1899, threadinfo=f7604000 task=f75cead0)
[17180051.840000] Stack: c0324600 00000818 000007ce 00000004 00000000 f7605bdc 04000000 00000000 
[17180051.840000]        ffd14ca4 00000000 f7605ea8 00000818 f77a4040 000001fe f755d080 f7976048 
[17180051.840000]        f76e2c80 f7605c50 f7976040 f75c4a80 c02bb612 f76e2c80 c02bb40e c02bd66a 
[17180051.840000] Call Trace:
[17180051.840000]  <c02bb612> ip6_output+0x3c/0x4c  <c02bb40e> ip6_output2+0x0/0x1c8
[17180051.840000]  <c02bd66a> ip6_push_pending_frames+0x250/0x390  <c02ce38e> udp_v6_push_pending_frames+0x13d/0x1a4
[17180051.840000]  <c02ce97f> udpv6_sendmsg+0x58a/0x953  <c02cd7c2> udpv6_recvmsg+0x20c/0x303
[17180051.840000]  <c02a6032> inet_sendmsg+0x4a/0x56  <c0260b82> sock_sendmsg+0xeb/0x105
[17180051.840000]  <c01c18cc> __next_cpu+0x22/0x31  <c01167c7> find_busiest_group+0xd6/0x305
[17180051.840000]  <c012f91e> autoremove_wake_function+0x0/0x57  <c01c662e> copy_from_user+0x46/0x7c
[17180051.840000]  <c01c662e> copy_from_user+0x46/0x7c  <c02626c9> sys_sendmsg+0x191/0x1f8
[17180051.840000]  <c01334c6> futex_wait+0x129/0x238  <c014b75c> find_extend_vma+0x29/0x7e
[17180051.840000]  <c0117927> default_wake_function+0x0/0x12  <c0132b91> futex_wake+0x4a/0xba
[17180051.840000]  <c01c662e> copy_from_user+0x46/0x7c  <c0262b6f> sys_socketcall+0x236/0x254
[17180051.840000]  <c0102be3> syscall_call+0x7/0xb 
[17180051.840000] Code: 50 60 e9 36 f9 ff ff 0f b6 44 24 1b 8b 54 24 2c 89 44 24 0c 8b 45 60 c7 04 24 00 46 32 c0 89 54 24 04 89 44 24 08 e8 50 07 e6 ff <0f> 0b fe 01 41 13 32 c0 e9 68 f8 ff ff 55 57 56 31 f6 53 83 ec 
[17180051.840000] EIP: [<c02bc6bd>] ip6_fragment+0x7f6/0x803 SS:ESP 0068:f7605bb8
---------------------------------------------------------------------------

I hope this helps.

Cheers,
-- 
cagri

On Tue, Aug 29, 2006 at 06:28:28PM +1000, Herbert Xu wrote:
> 
> Thanks.  Please try this patch and tell me if it prints anything out.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 4fb47a2..5e2e4ea 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -508,6 +508,10 @@ static int ip6_fragment(struct sk_buff *
>  	dev = rt->u.dst.dev;
>  	hlen = ip6_find_1stfragopt(skb, &prevhdr);
>  	nexthdr = *prevhdr;
> +	if (unlikely(hlen > skb->len)) {
> +		printk(KERN_CRIT "ip6_fragment: hlen = 0x%x, len = 0x%x, nexthdr=%d\n", hlen, skb->len, nexthdr);
> +		BUG();
> +	}
>  
>  	mtu = dst_mtu(&rt->u.dst);
>  	if (np && np->frag_size < mtu) {
