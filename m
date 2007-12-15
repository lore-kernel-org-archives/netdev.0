From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc5-mm1 -- inconsistent {in-softirq-W} -> {softirq-on-R}
   usage.
Date: Sat, 15 Dec 2007 19:42:11 +0100
Message-ID: <47642003.7090900@gmail.com>
References: <a44ae5cd0712141413u4ddbfd06gca259cfc3bc0ab1a@mail.gmail.com>	<20071214153633.5d8f609a.akpm@linux-foundation.org>	<a44ae5cd0712141958o10d9a320h3b8173019ac6b0eb@mail.gmail.com> <20071215031341.66dc0d05.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Miles Lane <miles.lane@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762506AbXLOSfz@vger.kernel.org>
In-Reply-To: <20071215031341.66dc0d05.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote, On 12/15/2007 12:13 PM:

> On Fri, 14 Dec 2007 22:58:24 -0500 "Miles Lane" <miles.lane@gmail.com=
> wrote:



=2E..

>> I applied the patch and then tried my test again.  This time my syst=
em
>> locked up.
>> Perhaps I should open a new thread for this, since the problem looks
>> pretty different.
>>
>> Dec 14 21:32:55 feargod kernel: process `cat' is using deprecated
>> sysctl (syscall) net.ipv6.neigh.default.retrans_time; Use
>> net.ipv6.neigh.default.retran
>> s_time_ms instead.
>> Dec 14 21:32:55 feargod kernel:
>> Dec 14 21:32:55 feargod kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>> Dec 14 21:32:55 feargod kernel: [ BUG: bad unlock balance detected! =
]
>> Dec 14 21:32:55 feargod kernel: ------------------------------------=
-
>> Dec 14 21:32:55 feargod kernel: cat/6180 is trying to release lock
>> (kkkkkkk=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDH3=EF=BF=BD=EF=BF=
=BD) at:
>> Dec 14 21:32:55 feargod kernel: [packet_seq_stop+0xe/0x10]
>> packet_seq_stop+0xe/0x10
>> Dec 14 21:32:55 feargod kernel: but there are no more locks to relea=
se!
>> Dec 14 21:32:55 feargod kernel:
>> Dec 14 21:32:55 feargod kernel: other info that might help us debug =
this:
>> Dec 14 21:32:55 feargod kernel: 2 locks held by cat/6180:
>> Dec 14 21:32:55 feargod kernel:  #0:  (&p->lock){--..}, at:
>> [crypto_algapi:seq_read+0x25/0x191c1] seq_read+0x25/0x26f
>> Dec 14 21:32:55 feargod kernel:  #1:
>> (&net->packet.sklist_lock){-.--}, at: [packet_seq_start+0x14/0x4d]
>> packet_seq_start+0x14/0x4d



Miles, I didn't check this yet, but since there were some considerable
changes, including locking, you could try with reverting some of these
last 3 patches to net/packet by Denis:

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.25.git;a=3Dhi=
story;f=3Dnet/packet/af_packet.c;h=3D485af5691d64270a02322925a6ccfad9d0=
2b7f78;hb=3DHEAD

Regards,
Jarek P.

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
