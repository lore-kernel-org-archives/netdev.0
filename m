From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Fri, 01 Jul 2016 10:23:16 +0200
Message-ID: <1467361396.11238.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57761E04.8030202@huawei.com>
	 <1467359847.11238.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5776258F.6080008@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5776258F.6080008@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-01 at 16:10 +0800, Ding Tianhong wrote:
> On 2016/7/1 15:57, Eric Dumazet wrote:
> > On Fri, 2016-07-01 at 15:38 +0800, Ding Tianhong wrote:
> > ...
> >>  net/ipv6/addrconf.c | 6 ++++++
> >>  1 file changed, 6 insertions(+)
> >>
> >> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >> index f555f4f..e294a3d 100644
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -3284,6 +3284,12 @@ restart:
> >>  		spin_unlock_bh(&addrconf_hash_lock);
> >>  	}
> >>  
> >> +	/*
> >> +	 * It is safe here to schedule out to avoid softlocking if preempt
> >> +	 * is disabled.
> >> +	 */
> >> +	cond_resched();
> >> +
> >>  	write_lock_bh(&idev->lock);
> >>  
> >>  	addrconf_del_rs_timer(idev);
> > 
> > Seeing you apparently cooked your patch against an old kernel (which
> > one ?) ...
> > 
> > I tried vanilla net-next kernel, and apparently I could not trigger the
> > softlockup you mentioned.
> > 
> > Are you sure current kernel has a bug to begin with ?
> > 
> have you disable the preempt? The problem will disappear if you enable the preempt voluntary or preempt.
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> 
> I test the 4.1 lts kernel and found this problem, and I didn't found any patch to fix this from linux 4.1, but I will try to test in 4.7 kernel version.

I usually do not have PREEMPT enabled in my kernels.

$ grep PREEMPT .config
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set

Also the whole script is quite fast on latest kernels. I am guessing you
are chasing an already fixed problem.
