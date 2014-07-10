From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 14:18:32 +0200
Message-ID: <CAG-2HqVOviqCYrKL-F3o_cR66EAe2skbL20pR48CmEikG1o-7g@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-11-git-send-email-teg@jklm.no> <87pphdh85q.fsf@nemi.mork.no>
 <CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com> <87d2ddh1zd.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d2ddh1zd.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 1:44 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Tom Gundersen <teg@jklm.no> writes:
>
>> The result of
>>
>> modprobe dummy numdummies=3D2
>>
>> is to create dummy0 and dummy1, always with the same names.
>>
>> The result of
>>
>> ip link add type dummy
>>
>> is to create dummyX, where X depends on what came before.
>
> Which is no different. That's exacly what happens when
> "modprobe dummy numdummies=3D2" creates the two first interfaces.
>
>
>  ip link add link wwan0 name dummy0 type vlan id 2
>  modprobe dummy numdummies=3D2
>
> ends up with dummy1 and dummy2 created by the dummy driver.
>
> You are trying to make up differences that just aren't there.

Ah, good point. You are right. So the dummy interfaces should be
labelled NET_NAME_ENUM.

I suppose the distinction should be that statically created devices
like these should be NET_NAME_PREDICTABLE only if they fail when the
name they want is already taken (rather than just picking the next
one).

Thanks for looking into this!

Cheers,

Tom
