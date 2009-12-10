From: Patrick McHardy <kaber@trash.net>
Subject: Re: Networking-related crash?
Date: Thu, 10 Dec 2009 12:01:33 +0100
Message-ID: <4B20D50D.5050403@trash.net>
References: <608c44bf0912090546s446bf973ne408e99661fdc56f@mail.gmail.com> <4B1FBE0A.4040107@redhat.com> <4B200E9E.4020107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, Adam Huffman <adam.huffman@gmail.com>,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B200E9E.4020107@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le 09/12/2009 16:11, Avi Kivity a =E9crit :
>> On 12/09/2009 03:46 PM, Adam Huffman wrote:
>>> I've been seeing lots of crashes on a new Dell Precision T7500,
>>> running the KVM in Fedora 12.  Finally managed to capture an Oops,
>>> which is shown below (hand-transcribed):
>>>
>>> BUG: unable to handle kernel paging request at 0000000000200200
>>> IP: [<ffffffff8139aab7>] destroy_conntrack+0x82/0x11f
>>> PGD 332d0e067 PUD 33453c067 PMD 0
>>> RIP: 0010:[<ffffffff8139aab7>]  [<ffffffff8139aab7>]
>>> destroy_conntrack+0x82/0x11f
>>> RSP: 0018:ffffc90000803bf0  EFLAGS: 00010202
>>> RAX: 0000000080000001 RBX: ffffffff816fb1a0 RCX: 000000000000752f
>>> RDX: 0000000000200200 RSI: 0000000000000011 RDI: ffffffff816fb1a0
>>> RBP: ffffc90000803c00 R08: ffff880336699438 R09: 0000000000aaa5e0
>>> R10: 00000002f54189d5 R11: 0000000000000001 R12: ffffffff819a92e0
>>> R13: ffffffffa029adcc R14: 0000000000000000 R15: ffff880632866c38
>>> FS:  00007fdd34b17710(0000) GS:ffffc90000800000(0000)
>>> knlGS:0000000000000000
>>> CS:  0010 DS: 002B ES: 002B CR0: 0000000080050033
>>> CR2: 0000000000200200 CR3: 00000003349c0000 CR4: 00000000000026e0
>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Process qemu-kvm (pid: 1759, threadinfo ffff88062e9e8000, task
>>> ffff880634945e00)
>>> Stack:
>>>   ffff880632866c00 ffff880634640c30 ffffc90000803c10 ffffffff813989=
c2
>>> <0>  ffffc90000803c30 ffffffff81374092 ffffc90000803c30 ffff8806328=
66c00
>>> <0>  ffffc90000803c50 ffffffff81373dd3 0000000200000000 ffff8806328=
66c00
>>> Call Trace:
>>>   <IRQ>
>>>   [<ffffffff813989c2>] nf_conntrack_destroy+0x1b/0x1d
>>>   [<ffffffff81374092>] skb_release_head_state+0x95/0xd7
>>>   [<ffffffff81373dd3>] __kfree_skb+0x16/0x81
>>>   [<ffffffff81373ed7>] kfree_skb+0x6a/0x72
>>>   [<ffffffffa029adcc>] ip6_mc_input+0x220/0x230 [ipv6]
>>>   [<ffffffffa029a3d1>] ip6_rcv_finish+0x27/0x2b [ipv6]
>>>   [<ffffffffa029a763>] ipv6_rcv+0x38e/0x3e5 [ipv6]
>>>   [<ffffffff8137bd91>] netif_receive_skb+0x402/0x427
>>>   ...
>>>   =20
> crash in :
> 	48 8b 43 08             mov    0x8(%rbx),%rax
> 	a8 01                   test   $0x1,%al
> 	48 89 02                mov    %rax,(%rdx)  << HERE >> RDX=3D0x20020=
0  (LIST_POISON2)
> 	75 04			jne    1f
> 	48 89 50 08             mov    %rdx,0x8(%rax)
> 1:	48 c7 43 10 00 02 20    movq   $0x200200,0x10(%rbx)
>=20
> 	if (!nf_ct_is_confirmed(ct)) {
> 		BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnno=
de));
> 		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);  <<=
 HERE >>
> 	}
> 	NF_CT_STAT_INC(net, delete);=20


I can't spot the problem. Adam, please send me your .config file.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
