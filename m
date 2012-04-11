From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Wed, 11 Apr 2012 14:20:40 +0200
Message-ID: <CA+1xoqd0JJ-Z+hmwgdZkBiu1anEh6iz1jJboULPp-drUzO37Ew@mail.gmail.com>
References: <201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
 <CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
 <201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
 <201204062044.EJE13062.OLMQtSVFHOFOJF@I-love.SAKURA.ne.jp>
 <20120406180905.GA10835@llnl.gov> <201204070906.HHC13855.QOSFVOMtFFLJOH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: garlick@llnl.gov, ericvh@gmail.com, oleg@redhat.com,
	eric.dumazet@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204070906.HHC13855.QOSFVOMtFFLJOH@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Yes but in the unlikely event that this happens, the effect is a sma=
ll
>> memory leak for the duration of the mount. =A0On the other hand if t=
he
>> fid is destroyed without successfully informing the server, then
>> subsequent operations that involve new file references will fail
>> when that fid number is reused, and the mount becomes unusable.
>
> I don't know whether Sasha's problem is caused by this patch or not.
> But p9_client_clunk() is called from many functions in fs/9p/ directo=
ry.
> They are assuming that p9_client_clunk() will call p9_fid_destroy() b=
ut
> this patch is breaking that assumption. I think this is the cause of =
hang which
> Sasha is experiencing because Sasha's trace shows that call_usermodeh=
elper() is
> blocked by functions in fs/9p/ directory. Seems inconsistency state p=
roblem.

I'd be happy to try out any other patches or help debugging this issue.

Which behavior did this patch fix exactly? can I just revert it and
try running without it?
