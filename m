From: Adam Huffman <adam.huffman@gmail.com>
Subject: Re: Networking-related crash?
Date: Mon, 14 Dec 2009 13:46:33 +0000
Message-ID: <608c44bf0912140546p481d7e5cg614d27609aacfa67@mail.gmail.com>
References: <608c44bf0912090546s446bf973ne408e99661fdc56f@mail.gmail.com>
	 <4B1FBE0A.4040107@redhat.com> <4B200E9E.4020107@gmail.com>
	 <4B20D50D.5050403@trash.net>
	 <608c44bf0912100718v42976b4kc6168fc30a8b8ef@mail.gmail.com>
	 <4B263A9D.3090102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:53509 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbZLNNqf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 08:46:35 -0500
In-Reply-To: <4B263A9D.3090102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 1:16 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> Adam Huffman wrote:
>> On Thu, Dec 10, 2009 at 11:01 AM, Patrick McHardy <kaber@trash.net> =
wrote:
>>> Eric Dumazet wrote:
>>>> Le 09/12/2009 16:11, Avi Kivity a =E9crit :
>>>>> On 12/09/2009 03:46 PM, Adam Huffman wrote:
>>>>>> I've been seeing lots of crashes on a new Dell Precision T7500,
>>>>>> running the KVM in Fedora 12. =A0Finally managed to capture an O=
ops,
>>>>>> which is shown below (hand-transcribed):
>>>>>>
>>>>>> BUG: unable to handle kernel paging request at 0000000000200200
>>>>>> IP: [<ffffffff8139aab7>] destroy_conntrack+0x82/0x11f
>>>>>> PGD 332d0e067 PUD 33453c067 PMD 0
>>>>>> RIP: 0010:[<ffffffff8139aab7>] =A0[<ffffffff8139aab7>]
>>>>>> destroy_conntrack+0x82/0x11f
>>>>>> RSP: 0018:ffffc90000803bf0 =A0EFLAGS: 00010202
>>>>>> RAX: 0000000080000001 RBX: ffffffff816fb1a0 RCX: 000000000000752=
f
>>>>>> RDX: 0000000000200200 RSI: 0000000000000011 RDI: ffffffff816fb1a=
0
>>>>>> RBP: ffffc90000803c00 R08: ffff880336699438 R09: 0000000000aaa5e=
0
>>>>>> R10: 00000002f54189d5 R11: 0000000000000001 R12: ffffffff819a92e=
0
>>>>>> R13: ffffffffa029adcc R14: 0000000000000000 R15: ffff880632866c3=
8
>>>>>> FS: =A000007fdd34b17710(0000) GS:ffffc90000800000(0000)
>>>>>> knlGS:0000000000000000
>>>>>> CS: =A00010 DS: 002B ES: 002B CR0: 0000000080050033
>>>>>> CR2: 0000000000200200 CR3: 00000003349c0000 CR4: 00000000000026e=
0
>>>>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000000000=
0
>>>>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000000040=
0
>>>>>> Process qemu-kvm (pid: 1759, threadinfo ffff88062e9e8000, task
>>>>>> ffff880634945e00)
>>>>>> Stack:
>>>>>> =A0 ffff880632866c00 ffff880634640c30 ffffc90000803c10 ffffffff8=
13989c2
>>>>>> <0> =A0ffffc90000803c30 ffffffff81374092 ffffc90000803c30 ffff88=
0632866c00
>>>>>> <0> =A0ffffc90000803c50 ffffffff81373dd3 0000000200000000 ffff88=
0632866c00
>>>>>> Call Trace:
>>>>>> =A0 <IRQ>
>>>>>> =A0 [<ffffffff813989c2>] nf_conntrack_destroy+0x1b/0x1d
>>>>>> =A0 [<ffffffff81374092>] skb_release_head_state+0x95/0xd7
>>>>>> =A0 [<ffffffff81373dd3>] __kfree_skb+0x16/0x81
>>>>>> =A0 [<ffffffff81373ed7>] kfree_skb+0x6a/0x72
>>>>>> =A0 [<ffffffffa029adcc>] ip6_mc_input+0x220/0x230 [ipv6]
>>>>>> =A0 [<ffffffffa029a3d1>] ip6_rcv_finish+0x27/0x2b [ipv6]
>>>>>> =A0 [<ffffffffa029a763>] ipv6_rcv+0x38e/0x3e5 [ipv6]
>>>>>> =A0 [<ffffffff8137bd91>] netif_receive_skb+0x402/0x427
>>>>>> =A0 ...
>>>>>>
>>>> crash in :
>>>> =A0 =A0 =A0 48 8b 43 08 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A00x8(%rb=
x),%rax
>>>> =A0 =A0 =A0 a8 01 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 test =A0 $0x=
1,%al
>>>> =A0 =A0 =A0 48 89 02 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A0%ra=
x,(%rdx) =A0<< HERE >> RDX=3D0x200200 =A0(LIST_POISON2)
>>>> =A0 =A0 =A0 75 04 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jne =A0 =A01=
f
>>>> =A0 =A0 =A0 48 89 50 08 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A0%rdx,0x=
8(%rax)
>>>> 1: =A0 =A048 c7 43 10 00 02 20 =A0 =A0movq =A0 $0x200200,0x10(%rbx=
)
>>>>
>>>> =A0 =A0 =A0 if (!nf_ct_is_confirmed(ct)) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(hlist_nulls_unhashed(&ct->tuple=
hash[IP_CT_DIR_ORIGINAL].hnnode));
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_nulls_del_rcu(&ct->tuplehash[IP_=
CT_DIR_ORIGINAL].hnnode); =A0<< HERE >>
>>>> =A0 =A0 =A0 }
>>>> =A0 =A0 =A0 NF_CT_STAT_INC(net, delete);
>>>
>>> I can't spot the problem. Adam, please send me your .config file.
>>>
>>>
>>
>> It's the standard Fedora .config, which is attached.
>>
>> As I stated in another message, the oops seems related to VT-d. =A0W=
ith
>> that disabled, the machine has been stable for nearly a day now.
>
> That probably only affects the timing of some race. Please also
> send me the IPv6 ruleset used on that machine. Thanks.
>

Again, it's the Fedora 12 default.  Here you go:

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p ipv6-icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
