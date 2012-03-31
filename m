From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sat, 31 Mar 2012 23:34:23 +0200
Message-ID: <20120331213423.GA21219@redhat.com>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com> <1333227549.2325.4051.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333227549.2325.4051.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/31, Eric Dumazet wrote:
>
> On Sat, 2012-03-31 at 19:51 +0200, Sasha Levin wrote:
> > Hi all,
> >
> > It appears that a hang may occur when destroying an ipv6 tunnel, which
> > I've reproduced several times in a KVM vm.

kernel version?

> > [ 1561.564172] INFO: task kworker/u:2:3140 blocked for more than 120 seconds.

And nobody else?

It would be nice to know what sysrq-t says, in particular the trace
of khelper thread is interesting.

> Something is wrong here, call_usermodehelper_exec ( ... UMH_WAIT_EXEC)
> should not block forever.

Yes, unless it triggers another request_module()...

Tetsuo, could you please take a look? Unlikely, but may be this
is fixed by your kmod-avoid-deadlock-by-recursive-kmod-call.patch
in -mm ?

Oleg.
