From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Fri, 22 May 2015 09:32:28 +0200
Message-ID: <1432279948.3493.2.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-21 at 18:44 +0800, Herbert Xu wrote:
> This patch makes use of the new AEAD interface which uses a single
> SG list instead of separate lists for the AD and plain text.

The CCM and GCM part seems to work, but GMAC causes a kernel crash:

[   26.143579] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   26.144406] IP: [<ffffffff811d9e7d>] scatterwalk_map_and_copy+0x3d/0xd0
[   26.145071] PGD da3a067 PUD d9ee067 PMD 0 
[   26.145514] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
[   26.146146] CPU: 1 PID: 661 Comm: hostapd Not tainted 4.0.0+ #860
[   26.146746] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   26.148333] task: ffff88000d9a4a20 ti: ffff880000070000 task.ti: ffff880000070000
[   26.149625] RIP: 0010:[<ffffffff811d9e7d>]  [<ffffffff811d9e7d>] scatterwalk_map_and_copy+0x3d/0xd0
[   26.151223] RSP: 0018:ffff8800000733b8  EFLAGS: 00010246
[   26.152156] RAX: 0000000000000000 RBX: 0000000000000010 RCX: 000077ff80000000
[   26.153396] RDX: 0000000080000000 RSI: 0000000000000000 RDI: ffff8800000733c8
[   26.153481] RBP: ffff880000073428 R08: 0000000000000001 R09: 0000000000000010
[   26.153481] R10: 0000000000000010 R11: 0000000000000012 R12: 0000000000000001
[   26.153481] R13: ffff8800000735f8 R14: 0000000000000000 R15: 0000000000000030
[   26.153481] FS:  00007f20eee60700(0000) GS:ffff88000f600000(0000) knlGS:0000000000000000
[   26.153481] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   26.153481] CR2: 0000000000000000 CR3: 000000000da2a000 CR4: 00000000000007a0
[   26.153481] Stack:
[   26.153481]  0000000000000000 0000000000000030 ffff8800000733d8 ffffffff811e05c6
[   26.153481]  ffff8800000733f8 ffffffff811df815 ffff8800000735f8 ffff880000073598
[   26.153481]  ffff880000073408 ffffffff811dfc86 ffff880000073438 ffff8800000735f8
[   26.153481] Call Trace:
[   26.153481]  [<ffffffff811e05c6>] ? shash_async_final+0x16/0x20
[   26.153481]  [<ffffffff811df815>] ? crypto_ahash_op+0x25/0x60
[   26.153481]  [<ffffffff811dfc86>] ? crypto_ahash_final+0x16/0x20
[   26.153481]  [<ffffffff811e3608>] gcm_enc_copy_hash+0x28/0x30
[   26.153481]  [<ffffffff811e36fc>] crypto_gcm_encrypt+0xec/0x100
[   26.153481]  [<ffffffff811e3610>] ? gcm_enc_copy_hash+0x30/0x30
[   26.153481]  [<ffffffff811da875>] old_crypt+0xc5/0xe0
[   26.153481]  [<ffffffff811da8cd>] old_encrypt+0x1d/0x20
[   26.153481]  [<ffffffff814b688b>] ieee80211_aes_gmac+0x21b/0x230
[   26.153481]  [<ffffffff811e3710>] ? crypto_gcm_encrypt+0x100/0x100
[   26.153481]  [<ffffffff811e2f10>] ? __gcm_hash_final_done+0x60/0x60
[   26.153481]  [<ffffffff814b66a4>] ? ieee80211_aes_gmac+0x34/0x230
[   26.153481]  [<ffffffff81498621>] ieee80211_crypto_aes_gmac_encrypt+0x191/0x1a0
[   26.153481]  [<ffffffff8153b794>] ieee80211_tx_h_encrypt+0x67/0x77
[   26.153481]  [<ffffffff814cd496>] invoke_tx_handlers+0xe6/0x1b0

johannes
