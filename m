From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 14:47:23 +0300
Message-ID: <4C725FCB.2000304@fs.uni-ruse.bg>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg> <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:56101 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751453Ab0HWLr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 07:47:26 -0400
In-Reply-To: <20100821080735.GA2409@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 21.8.2010 =D0=B3. 11:07, Jarek Poplawski =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0:
> On Sat, Aug 21, 2010 at 09:50:58AM +0200, Eric Dumazet wrote:
>> Le samedi 21 ao=C3=BBt 2010 =C3=A0 09:47 +0200, Jarek Poplawski a =C3=
=A9crit :
>>> On Fri, Aug 20, 2010 at 09:38:35PM +0200, Jarek Poplawski wrote:
>>>> Plamen Petrov wrote, On 20.08.2010 12:53:
>>>>> So, I guess its David and Herbert's turn?...
>>>>
>>>> If you're bored in the meantime I'd suggest to do check the realte=
k
>>>> driver eg:
>>>> - for locking with the patch below,
>>>> - to turn off with ethtool its tx-checksumming and/or scatter-gath=
er,
>>>
>>> After rethinking, it's almost impossible this patch could change
>>> anything here, so don't bother, but consider mainly the second
>>> proposal.
>>>
>>> Jarek P.
>>
>> Indeed ;)
>>
>> Its true that not many nics use the skb_copy_and_csum_dev() helper,
>> maybe this one must be updated somehow ?
>>
> Yes, it seems it should be possible at least to handle the bug with
> a warning and error return, considering Plamen's problems with gettin=
g
> the trace.
>
> Jarek P.

Well, here is the current status:

Last I promised I will stay on 2.6.36-rc1-git for as long as possible,
so here is what I achieved:

>
root@fs:/boot# w; uname -a
>  12:08:18 up 3 days, 24 min,  1 user,  load average: 1.21, 1.29, 1.17
> USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
> root     pts/0    192.168.10.159   12:04    0.00s  0.02s  0.00s w
> Linux fs 2.6.36-rc1-FS-00127-g763008c #1 SMP Thu Aug 19 07:10:57 UTC =
2010 i686 Intel(R) Pentium(R) D CPU 3.00GHz GenuineIntel GNU/Linux

Yeah, 3 days and counting, right until I decided to try the freshly
announced 2.6.36-rc2.

So I upgraded the kernel, but left the scripts that turn GRO off for
the tg3 card still run at system startup. This way the system ran for
2 and a half hours, when I decided its time to try turning GRO on.

I first tried to turn GRO on for the tg3 nic, and the system oopsed
immediately (if the panic screen is necessary - please, ask for it).

After the system came back, I tried turning GRO on for the 2 RealTek
8139 nics, too, but ethtool only accepted turning GRO off.

And unfortunately, I can't test if other nics will fail the same way
as the motherboard integrated tg3 I have does, so for now, this is
only a tg3 + GRO on problem; I don't have any other hardware to test
with available.

Thanks,
Plamen
