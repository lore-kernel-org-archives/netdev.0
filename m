From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net] skge: add dma_mapping check
Date: Sat, 10 Aug 2013 13:51:49 +0200
Message-ID: <52062955.90102@gmail.com>
References: <20130804172234.345913ae@nehalam.linuxnetplumber.net> <20130804.183553.514470399074672614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020208050502010408030602"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:43638 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757720Ab3HJLvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 07:51:53 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so2535853eak.4
        for <netdev@vger.kernel.org>; Sat, 10 Aug 2013 04:51:52 -0700 (PDT)
In-Reply-To: <20130804.183553.514470399074672614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020208050502010408030602
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 05.08.2013 03:35, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sun, 4 Aug 2013 17:22:34 -0700
> 
>> This old driver never checked for DMA mapping errors.
>> Causing splats with the new DMA mapping checks:
>> 	WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
>> 	skge 0000:01:09.0: DMA-API: device driver failed to check map
>>
>> Add checks and unwind code.
>>
>> Reported-by: poma <pomidorabelisima@gmail.com>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Applied, but:
> 
>> -static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
>> +static int skge_rx_setup(struct skge_port *skge, struct skge_element *e,
>>  			  struct sk_buff *skb, unsigned int bufsize)
> 
> I reflowed the argument indentation for this in the final commit.
> 
> Thanks.
> 

skge-add-dma_mapping-check.patch
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/patch/drivers/net/ethernet/marvell?id=136d8f377e1575463b47840bc5f1b22d94bf8f63

/usr/lib/modules/3.11.0-0.rc4.git2.1.fc20.x86_64/updates/skge.ko

skge: module verification failed: signature and/or required key missing
- tainting kernel
skge: 1.14 addr 0xfbffc000 irq 19 chip Yukon rev 1
skge 0000:01:09.0 eth0: addr nn:nn:nn:nn:nn:nn
skge 0000:01:09.0 enp1s9: enabling interface
skge 0000:01:09.0 enp1s9: Link is up at 1000 Mbps, full duplex, flow
control both
IPv6: ADDRCONF(NETDEV_CHANGE): enp1s9: link becomes ready

Starting Nmap 6.25

------------[ cut here ]------------
WARNING: CPU: 2 PID: 2443 at lib/dma-debug.c:986 check_sync+0x4bc/0x580()
skge 0000:01:09.0: DMA-API: device driver tries to sync DMA memory it
has not allocated [device address=0x00000000cf390040] [size=60 bytes]
Modules linked in: skge(OF) raid1 nouveau video mxm_wmi i2c_algo_bit
drm_kms_helper ttm drm i2c_core wmi
CPU: 2 PID: 2443 Comm: nmap Tainted: GF          O
3.11.0-0.rc4.git2.1.fc20.x86_64 #1
Hardware name: Gigabyte Technology Co., Ltd. M720-US3/M720-US3, BIOS F7n
09/07/2010
 0000000000000009 ffff88012aa03c48 ffffffff81723ac3 ffff88012aa03c90
 ffff88012aa03c80 ffffffff8107462d ffff88012837c2b0 000000000000003c
 ffff880128363470 00000000cf390040 ffff880126f79160 ffff88012aa03ce0
Call Trace:
 <IRQ>  [<ffffffff81723ac3>] dump_stack+0x54/0x74
 [<ffffffff8107462d>] warn_slowpath_common+0x7d/0xa0
 [<ffffffff8107469c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff81392a5c>] check_sync+0x4bc/0x580
 [<ffffffff8138519e>] ? debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff81392b6b>] debug_dma_sync_single_for_cpu+0x4b/0x50
 [<ffffffff810e6b6c>] ? trace_hardirqs_on_caller+0xac/0x1c0
 [<ffffffff815d9390>] ? build_skb+0x30/0x1d0
 [<ffffffff815db349>] ? __netdev_alloc_skb+0x89/0xf0
 [<ffffffffa01c7e21>] skge_poll+0x3a1/0x9f0 [skge]
 [<ffffffff815edb41>] ? net_rx_action+0xa1/0x380
 [<ffffffff815edc12>] net_rx_action+0x172/0x380
 [<ffffffff8107b4a7>] __do_softirq+0x107/0x410
 [<ffffffff8107b985>] irq_exit+0xc5/0xd0
 [<ffffffff81738c16>] do_IRQ+0x56/0xc0
 [<ffffffff8172d432>] common_interrupt+0x72/0x72
 <EOI>  [<ffffffff81721f92>] ? __slab_alloc+0x4c2/0x526
 [<ffffffff810e6bbd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff815db08e>] ? __alloc_skb+0x7e/0x2b0
 [<ffffffff811d2d71>] __kmalloc_node_track_caller+0x1a1/0x410
 [<ffffffff815db08e>] ? __alloc_skb+0x7e/0x2b0
 [<ffffffff815da8a1>] __kmalloc_reserve.isra.25+0x31/0x90
 [<ffffffff815db08e>] __alloc_skb+0x7e/0x2b0
 [<ffffffff815d754e>] sock_alloc_send_pskb+0x27e/0x400
 [<ffffffff815d76e5>] sock_alloc_send_skb+0x15/0x20
 [<ffffffff816614af>] raw_sendmsg+0x74f/0xc50
 [<ffffffff81660e7d>] ? raw_sendmsg+0x11d/0xc50
 [<ffffffff8130246d>] ? avc_has_perm_flags+0x16d/0x350
 [<ffffffff81302329>] ? avc_has_perm_flags+0x29/0x350
 [<ffffffff810b797f>] ? local_clock+0x5f/0x70
 [<ffffffff810e3fcf>] ? lock_release_holdtime.part.28+0xf/0x1a0
 [<ffffffff816723a7>] inet_sendmsg+0x117/0x230
 [<ffffffff81672295>] ? inet_sendmsg+0x5/0x230
 [<ffffffff815d0939>] sock_sendmsg+0x99/0xd0
 [<ffffffff810e346d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff810e9738>] ? lock_release_non_nested+0x308/0x350
 [<ffffffff811312e7>] ? rcu_irq_exit+0x77/0xc0
 [<ffffffff8172d4f3>] ? retint_restore_args+0x13/0x13
 [<ffffffff815d0e94>] SYSC_sendto+0x124/0x1d0
 [<ffffffff817369c5>] ? sysret_check+0x22/0x5d
 [<ffffffff810e6bbd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8137af2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815d1ffe>] SyS_sendto+0xe/0x10
 [<ffffffff81736999>] system_call_fastpath+0x16/0x1b
---[ end trace ef4521ca4028fd28 ]---


poma




--------------020208050502010408030602
Content-Type: text/plain; charset=UTF-8;
 name="skge-add-dma_mapping-check-3.11.0-0.rc4.git2.1.fc20.x86_64.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="skge-add-dma_mapping-check-3.11.0-0.rc4.git2.1.fc20.x86_64.t";
 filename*1="xt"

CnNrZ2UtYWRkLWRtYV9tYXBwaW5nLWNoZWNrLnBhdGNoCmh0dHBzOi8vZ2l0Lmtlcm5lbC5v
cmcvY2dpdC9saW51eC9rZXJuZWwvZ2l0L25leHQvbGludXgtbmV4dC5naXQvcGF0Y2gvZHJp
dmVycy9uZXQvZXRoZXJuZXQvbWFydmVsbD9pZD0xMzZkOGYzNzdlMTU3NTQ2M2I0Nzg0MGJj
NWYxYjIyZDk0YmY4ZjYzCgovdXNyL2xpYi9tb2R1bGVzLzMuMTEuMC0wLnJjNC5naXQyLjEu
ZmMyMC54ODZfNjQvdXBkYXRlcy9za2dlLmtvCgpza2dlOiBtb2R1bGUgdmVyaWZpY2F0aW9u
IGZhaWxlZDogc2lnbmF0dXJlIGFuZC9vciByZXF1aXJlZCBrZXkgbWlzc2luZyAtIHRhaW50
aW5nIGtlcm5lbApza2dlOiAxLjE0IGFkZHIgMHhmYmZmYzAwMCBpcnEgMTkgY2hpcCBZdWtv
biByZXYgMQpza2dlIDAwMDA6MDE6MDkuMCBldGgwOiBhZGRyIG5uOm5uOm5uOm5uOm5uOm5u
CnNrZ2UgMDAwMDowMTowOS4wIGVucDFzOTogZW5hYmxpbmcgaW50ZXJmYWNlCnNrZ2UgMDAw
MDowMTowOS4wIGVucDFzOTogTGluayBpcyB1cCBhdCAxMDAwIE1icHMsIGZ1bGwgZHVwbGV4
LCBmbG93IGNvbnRyb2wgYm90aApJUHY2OiBBRERSQ09ORihORVRERVZfQ0hBTkdFKTogZW5w
MXM5OiBsaW5rIGJlY29tZXMgcmVhZHkKClN0YXJ0aW5nIE5tYXAgNi4yNSAKCi0tLS0tLS0t
LS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpXQVJOSU5HOiBDUFU6IDIgUElEOiAyNDQz
IGF0IGxpYi9kbWEtZGVidWcuYzo5ODYgY2hlY2tfc3luYysweDRiYy8weDU4MCgpCnNrZ2Ug
MDAwMDowMTowOS4wOiBETUEtQVBJOiBkZXZpY2UgZHJpdmVyIHRyaWVzIHRvIHN5bmMgRE1B
IG1lbW9yeSBpdCBoYXMgbm90IGFsbG9jYXRlZCBbZGV2aWNlIGFkZHJlc3M9MHgwMDAwMDAw
MGNmMzkwMDQwXSBbc2l6ZT02MCBieXRlc10KTW9kdWxlcyBsaW5rZWQgaW46IHNrZ2UoT0Yp
IHJhaWQxIG5vdXZlYXUgdmlkZW8gbXhtX3dtaSBpMmNfYWxnb19iaXQgZHJtX2ttc19oZWxw
ZXIgdHRtIGRybSBpMmNfY29yZSB3bWkKQ1BVOiAyIFBJRDogMjQ0MyBDb21tOiBubWFwIFRh
aW50ZWQ6IEdGICAgICAgICAgIE8gMy4xMS4wLTAucmM0LmdpdDIuMS5mYzIwLng4Nl82NCAj
MQpIYXJkd2FyZSBuYW1lOiBHaWdhYnl0ZSBUZWNobm9sb2d5IENvLiwgTHRkLiBNNzIwLVVT
My9NNzIwLVVTMywgQklPUyBGN24gMDkvMDcvMjAxMAogMDAwMDAwMDAwMDAwMDAwOSBmZmZm
ODgwMTJhYTAzYzQ4IGZmZmZmZmZmODE3MjNhYzMgZmZmZjg4MDEyYWEwM2M5MAogZmZmZjg4
MDEyYWEwM2M4MCBmZmZmZmZmZjgxMDc0NjJkIGZmZmY4ODAxMjgzN2MyYjAgMDAwMDAwMDAw
MDAwMDAzYwogZmZmZjg4MDEyODM2MzQ3MCAwMDAwMDAwMGNmMzkwMDQwIGZmZmY4ODAxMjZm
NzkxNjAgZmZmZjg4MDEyYWEwM2NlMApDYWxsIFRyYWNlOgogPElSUT4gIFs8ZmZmZmZmZmY4
MTcyM2FjMz5dIGR1bXBfc3RhY2srMHg1NC8weDc0CiBbPGZmZmZmZmZmODEwNzQ2MmQ+XSB3
YXJuX3Nsb3dwYXRoX2NvbW1vbisweDdkLzB4YTAKIFs8ZmZmZmZmZmY4MTA3NDY5Yz5dIHdh
cm5fc2xvd3BhdGhfZm10KzB4NGMvMHg1MAogWzxmZmZmZmZmZjgxMzkyYTVjPl0gY2hlY2tf
c3luYysweDRiYy8weDU4MAogWzxmZmZmZmZmZjgxMzg1MTllPl0gPyBkZWJ1Z19jaGVja19u
b19vYmpfZnJlZWQrMHgxNGUvMHgyNTAKIFs8ZmZmZmZmZmY4MTM5MmI2Yj5dIGRlYnVnX2Rt
YV9zeW5jX3NpbmdsZV9mb3JfY3B1KzB4NGIvMHg1MAogWzxmZmZmZmZmZjgxMGU2YjZjPl0g
PyB0cmFjZV9oYXJkaXJxc19vbl9jYWxsZXIrMHhhYy8weDFjMAogWzxmZmZmZmZmZjgxNWQ5
MzkwPl0gPyBidWlsZF9za2IrMHgzMC8weDFkMAogWzxmZmZmZmZmZjgxNWRiMzQ5Pl0gPyBf
X25ldGRldl9hbGxvY19za2IrMHg4OS8weGYwCiBbPGZmZmZmZmZmYTAxYzdlMjE+XSBza2dl
X3BvbGwrMHgzYTEvMHg5ZjAgW3NrZ2VdCiBbPGZmZmZmZmZmODE1ZWRiNDE+XSA/IG5ldF9y
eF9hY3Rpb24rMHhhMS8weDM4MAogWzxmZmZmZmZmZjgxNWVkYzEyPl0gbmV0X3J4X2FjdGlv
bisweDE3Mi8weDM4MAogWzxmZmZmZmZmZjgxMDdiNGE3Pl0gX19kb19zb2Z0aXJxKzB4MTA3
LzB4NDEwCiBbPGZmZmZmZmZmODEwN2I5ODU+XSBpcnFfZXhpdCsweGM1LzB4ZDAKIFs8ZmZm
ZmZmZmY4MTczOGMxNj5dIGRvX0lSUSsweDU2LzB4YzAKIFs8ZmZmZmZmZmY4MTcyZDQzMj5d
IGNvbW1vbl9pbnRlcnJ1cHQrMHg3Mi8weDcyCiA8RU9JPiAgWzxmZmZmZmZmZjgxNzIxZjky
Pl0gPyBfX3NsYWJfYWxsb2MrMHg0YzIvMHg1MjYKIFs8ZmZmZmZmZmY4MTBlNmJiZD5dID8g
dHJhY2VfaGFyZGlycXNfb25fY2FsbGVyKzB4ZmQvMHgxYzAKIFs8ZmZmZmZmZmY4MTVkYjA4
ZT5dID8gX19hbGxvY19za2IrMHg3ZS8weDJiMAogWzxmZmZmZmZmZjgxMWQyZDcxPl0gX19r
bWFsbG9jX25vZGVfdHJhY2tfY2FsbGVyKzB4MWExLzB4NDEwCiBbPGZmZmZmZmZmODE1ZGIw
OGU+XSA/IF9fYWxsb2Nfc2tiKzB4N2UvMHgyYjAKIFs8ZmZmZmZmZmY4MTVkYThhMT5dIF9f
a21hbGxvY19yZXNlcnZlLmlzcmEuMjUrMHgzMS8weDkwCiBbPGZmZmZmZmZmODE1ZGIwOGU+
XSBfX2FsbG9jX3NrYisweDdlLzB4MmIwCiBbPGZmZmZmZmZmODE1ZDc1NGU+XSBzb2NrX2Fs
bG9jX3NlbmRfcHNrYisweDI3ZS8weDQwMAogWzxmZmZmZmZmZjgxNWQ3NmU1Pl0gc29ja19h
bGxvY19zZW5kX3NrYisweDE1LzB4MjAKIFs8ZmZmZmZmZmY4MTY2MTRhZj5dIHJhd19zZW5k
bXNnKzB4NzRmLzB4YzUwCiBbPGZmZmZmZmZmODE2NjBlN2Q+XSA/IHJhd19zZW5kbXNnKzB4
MTFkLzB4YzUwCiBbPGZmZmZmZmZmODEzMDI0NmQ+XSA/IGF2Y19oYXNfcGVybV9mbGFncysw
eDE2ZC8weDM1MAogWzxmZmZmZmZmZjgxMzAyMzI5Pl0gPyBhdmNfaGFzX3Blcm1fZmxhZ3Mr
MHgyOS8weDM1MAogWzxmZmZmZmZmZjgxMGI3OTdmPl0gPyBsb2NhbF9jbG9jaysweDVmLzB4
NzAKIFs8ZmZmZmZmZmY4MTBlM2ZjZj5dID8gbG9ja19yZWxlYXNlX2hvbGR0aW1lLnBhcnQu
MjgrMHhmLzB4MWEwCiBbPGZmZmZmZmZmODE2NzIzYTc+XSBpbmV0X3NlbmRtc2crMHgxMTcv
MHgyMzAKIFs8ZmZmZmZmZmY4MTY3MjI5NT5dID8gaW5ldF9zZW5kbXNnKzB4NS8weDIzMAog
WzxmZmZmZmZmZjgxNWQwOTM5Pl0gc29ja19zZW5kbXNnKzB4OTkvMHhkMAogWzxmZmZmZmZm
ZjgxMGUzNDZkPl0gPyB0cmFjZV9oYXJkaXJxc19vZmYrMHhkLzB4MTAKIFs8ZmZmZmZmZmY4
MTBlOTczOD5dID8gbG9ja19yZWxlYXNlX25vbl9uZXN0ZWQrMHgzMDgvMHgzNTAKIFs8ZmZm
ZmZmZmY4MTEzMTJlNz5dID8gcmN1X2lycV9leGl0KzB4NzcvMHhjMAogWzxmZmZmZmZmZjgx
NzJkNGYzPl0gPyByZXRpbnRfcmVzdG9yZV9hcmdzKzB4MTMvMHgxMwogWzxmZmZmZmZmZjgx
NWQwZTk0Pl0gU1lTQ19zZW5kdG8rMHgxMjQvMHgxZDAKIFs8ZmZmZmZmZmY4MTczNjljNT5d
ID8gc3lzcmV0X2NoZWNrKzB4MjIvMHg1ZAogWzxmZmZmZmZmZjgxMGU2YmJkPl0gPyB0cmFj
ZV9oYXJkaXJxc19vbl9jYWxsZXIrMHhmZC8weDFjMAogWzxmZmZmZmZmZjgxMzdhZjJlPl0g
PyB0cmFjZV9oYXJkaXJxc19vbl90aHVuaysweDNhLzB4M2YKIFs8ZmZmZmZmZmY4MTVkMWZm
ZT5dIFN5U19zZW5kdG8rMHhlLzB4MTAKIFs8ZmZmZmZmZmY4MTczNjk5OT5dIHN5c3RlbV9j
YWxsX2Zhc3RwYXRoKzB4MTYvMHgxYgotLS1bIGVuZCB0cmFjZSBlZjQ1MjFjYTQwMjhmZDI4
IF0tLS0KCgo=
--------------020208050502010408030602--
