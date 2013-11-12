From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 12 Nov 2013 08:56:25 +0100
Message-ID: <87y54u59zq.fsf@natisbad.org>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, edumazet@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> (Cong Wang's
	message of "Tue, 12 Nov 2013 06:48:59 +0000 (UTC)")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for the pointer. See below.

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Sun, 10 Nov 2013 at 13:53 GMT, Arnaud Ebalard <arno@natisbad.org> wrote:
>> Hi,
>>
>> I decided to upgrade the kernel on one of my ReadyNAS 102 from 3.11.1 to 
>> 3.11.7. The device is based on Marvell Armada 370 SoC and uses mvneta
>> driver. Mine runs Debian armel unstable but I can confirm the issue also
>> happens on a debian harmhf unstable.
>>
> [...]
>>
>> Then, knowing that, I started a git bisect session on stable tree to end
>> up with the following suspects. I failed to go any further to a single
>> commit, due to crashes, but I could recompile a kernel w/ debug info and
>> report what I get if neeeded.
>>
>> commit dc0791aee672 tcp: do not forget FIN in tcp_shifted_skb()     [bad]
>> commit 18ddf5127c9f tcp: must unclone packets before mangling them
>> commit 80bd5d8968d8 tcp: TSQ can use a dynamic limit
>> commit dbeb18b22197 tcp: TSO packets automatic sizing
>> commit 50704410d014 Linux 3.11.6                                    [good]
>>
>
> This regression is probably introduced the last TSQ commit, Eric has a patch
> for mvneta in the other thread:
>
> http://article.gmane.org/gmane.linux.network/290359

I had some offline (*) discussions w/ Eric and did some test w/ the patches
he sent. It does not fix the regression I see. It would be nice if someone
w/ the hardware and more knowledge of mvneta driver could reproduce the
issue and spend some time on it.

That been said, even if the driver is most probably not the only one to
blame here (considering the result of bisect and current thread on
netdev), I never managed to get the performance I have on my ReadyNAS
Duo v2 (i.e. 108MB/s for a file served by an Apache) with a mvneta-based
platform (RN102, RN104 or RN2120). Understanding why is on an already a
long todo list. 

Cheers,

a+

(*): for some reasons, my messages to netdev and stable are not published
even though I can interact w/ {majordomo,autoanswer}@vger.kernel.org. I
poked postmaster@ bug got no reply yet.
