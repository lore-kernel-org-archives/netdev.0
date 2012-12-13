From: Jason Wang <jasowang@redhat.com>
Subject: Re: GPF in skb_flow_dissect
Date: Thu, 13 Dec 2012 13:40:25 +0800
Message-ID: <50C96A49.2030404@redhat.com>
References: <20121213041644.GB1611@redhat.com> <1355376177.12271.244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750829Ab2LMFkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 00:40:40 -0500
In-Reply-To: <1355376177.12271.244.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2012 01:22 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Wed, 2012-12-12 at 23:16 -0500, Dave Jones wrote:
>> Since todays net merge, I see this when I start openvpn..
>>
>> general protection fault: 0000 [#1] PREEMPT SMP 
>> Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables xfs iTCO_wdt iTCO_vendor_support snd_emu10k1 snd_util_mem snd_ac97_codec coretemp ac97_bus microcode snd_hwdep snd_seq pcspkr snd_pcm snd_page_alloc snd_timer lpc_ich i2c_i801 snd_rawmidi mfd_core snd_seq_device snd e1000e soundcore emu10k1_gp gameport i82975x_edac edac_core vhost_net tun macvtap macvlan kvm_intel kvm binfmt_misc nfsd auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c zlib_deflate firewire_ohci sata_sil firewire_core crc_itu_t radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core floppy
>> CPU 0 
>> Pid: 1381, comm: openvpn Not tainted 3.7.0+ #14                  /D975XBX
>> RIP: 0010:[<ffffffff815b54a4>]  [<ffffffff815b54a4>] skb_flow_dissect+0x314/0x3e0
>> RSP: 0018:ffff88007d0d9c48  EFLAGS: 00010206
>> RAX: 000000000000055d RBX: 6b6b6b6b6b6b6b4b RCX: 1471030a0180040a
>> RDX: 0000000000000005 RSI: 00000000ffffffe0 RDI: ffff8800ba83fa80
>> RBP: ffff88007d0d9cb8 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000101 R12: ffff8800ba83fa80
>> R13: 0000000000000008 R14: ffff88007d0d9cc8 R15: ffff8800ba83fa80
>> FS:  00007f6637104800(0000) GS:ffff8800bf600000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00007f563f5b01c4 CR3: 000000007d140000 CR4: 00000000000007f0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process openvpn (pid: 1381, threadinfo ffff88007d0d8000, task ffff8800a540cd60)
>> Stack:
>>  ffff8800ba83fa80 0000000000000296 0000000000000000 0000000000000000
>>  ffff88007d0d9cc8 ffffffff815bcff4 ffff88007d0d9ce8 ffffffff815b1831
>>  ffff88007d0d9ca8 00000000703f6364 ffff8800ba83fa80 0000000000000000
>> Call Trace:
>>  [<ffffffff815bcff4>] ? netif_rx+0x114/0x4c0
>>  [<ffffffff815b1831>] ? skb_copy_datagram_from_iovec+0x61/0x290
>>  [<ffffffff815b672a>] __skb_get_rxhash+0x1a/0xd0
>>  [<ffffffffa03b9538>] tun_get_user+0x418/0x810 [tun]
>>  [<ffffffff8135f468>] ? delay_tsc+0x98/0xf0
>>  [<ffffffff8109605c>] ? __rcu_read_unlock+0x5c/0xa0
>>  [<ffffffffa03b9a41>] tun_chr_aio_write+0x81/0xb0 [tun]
>>  [<ffffffff81145011>] ? __buffer_unlock_commit+0x41/0x50
>>  [<ffffffff811db917>] do_sync_write+0xa7/0xe0
>>  [<ffffffff811dc01f>] vfs_write+0xaf/0x190
>>  [<ffffffff811dc375>] sys_write+0x55/0xa0
>>  [<ffffffff81705540>] tracesys+0xdd/0xe2
>> Code: 41 8b 44 24 68 41 2b 44 24 6c 01 de 29 f0 83 f8 03 0f 8e a0 00 00 00 48 63 de 49 03 9c 24 e0 00 00 00 48 85 db 0f 84 72 fe ff ff <8b> 03 41 89 46 08 b8 01 00 00 00 e9 43 fd ff ff 0f 1f 40 00 48 
>> RIP  [<ffffffff815b54a4>] skb_flow_dissect+0x314/0x3e0
>>  RSP <ffff88007d0d9c48>
>> ---[ end trace 6d42c834c72c002e ]---
>>
>>
>> Faulting instruction is
>>
>>    0:	8b 03                	mov    (%rbx),%eax
>>
>> rbx is slab poison (-20) so this looks like a use-after-free here...
>>
>>                         flow->ports = *ports;
>>  314:   8b 03                   mov    (%rbx),%eax
>>  316:   41 89 46 08             mov    %eax,0x8(%r14)
>>
>> in the inlined skb_header_pointer in skb_flow_dissect
>>
>> 	Dave
>>
> Yes, commit 7694a3acc55a7 added this bug
>
> Its illegal to use skb after call to netif_rx_ni(skb);
>
> I would try following patch.
>
> Thanks !
>
> [PATCH] tuntap: dont use skb after netif_rx_ni(skb)
>
> commit 96442e4242 (tuntap: choose the txq based on rxq) added
> a use after free.
>
> Cache rxhash in a temp variable before calling netif_rx_ni()
>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Acked-by: Jason Wang <jasowang@redhat.com>
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 2ac2164..40b426e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -297,13 +297,12 @@ static void tun_flow_cleanup(unsigned long data)
>  	spin_unlock_bh(&tun->lock);
>  }
>  
> -static void tun_flow_update(struct tun_struct *tun, struct sk_buff *skb,
> +static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
>  			    u16 queue_index)
>  {
>  	struct hlist_head *head;
>  	struct tun_flow_entry *e;
>  	unsigned long delay = tun->ageing_time;
> -	u32 rxhash = skb_get_rxhash(skb);
>  
>  	if (!rxhash)
>  		return;
> @@ -1010,6 +1009,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	int copylen;
>  	bool zerocopy = false;
>  	int err;
> +	u32 rxhash;
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if ((len -= sizeof(pi)) > total_len)
> @@ -1162,12 +1162,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  	}
>  
> +	rxhash = skb_get_rxhash(skb);
>  	netif_rx_ni(skb);
>  
>  	tun->dev->stats.rx_packets++;
>  	tun->dev->stats.rx_bytes += len;
>  
> -	tun_flow_update(tun, skb, tfile->queue_index);
> +	tun_flow_update(tun, rxhash, tfile->queue_index);
>  	return total_len;
>  }
>  
>
>
