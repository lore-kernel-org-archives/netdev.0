From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sat, 31 Mar 2012 23:43:19 +0200
Message-ID: <CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com>
 <1333227549.2325.4051.camel@edumazet-glaptop> <20120331213423.GA21219@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120331213423.GA21219@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 31, 2012 at 11:34 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 03/31, Eric Dumazet wrote:
>>
>> On Sat, 2012-03-31 at 19:51 +0200, Sasha Levin wrote:
>> > Hi all,
>> >
>> > It appears that a hang may occur when destroying an ipv6 tunnel, which
>> > I've reproduced several times in a KVM vm.
>
> kernel version?

latest linux-next

>> > [ 1561.564172] INFO: task kworker/u:2:3140 blocked for more than 120 seconds.
>
> And nobody else?

Some more messages follow a bit later which get stuck in vfs related code.

> It would be nice to know what sysrq-t says, in particular the trace
> of khelper thread is interesting.

Sure, I'll get one when it happens again.

>> Something is wrong here, call_usermodehelper_exec ( ... UMH_WAIT_EXEC)
>> should not block forever.
>
> Yes, unless it triggers another request_module()...
>
> Tetsuo, could you please take a look? Unlikely, but may be this
> is fixed by your kmod-avoid-deadlock-by-recursive-kmod-call.patch
> in -mm ?
>
> Oleg.
>
