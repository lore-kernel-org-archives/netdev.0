From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Thu, 12 May 2016 00:47:29 +0200
Message-ID: <ff0dc5d3-03c8-0316-71ed-e70426840773@stressinduktion.org>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <1462960104.4444.37.camel@redhat.com>
 <1462972112.23934.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1462977516.4444.73.camel@redhat.com>
 <CANn89iJOEpoYKS+=VU-zVEcs2geRF07nii_VdwCX1anHmhoodQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJOEpoYKS+=VU-zVEcs2geRF07nii_VdwCX1anHmhoodQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.05.2016 16:45, Eric Dumazet wrote:
> On Wed, May 11, 2016 at 7:38 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> 
>> Uh, we have likely the same issue in the net_rx_action() function, which
>> also execute with bh disabled and check for jiffies changes even on
>> single core hosts ?!?
> 
> That is why we have a loop break after netdev_budget=300 packets.
> And a sysctl to eventually tune this.
> 
> Same issue for softirq handler, look at commit
> 34376a50fb1fa095b9d0636fa41ed2e73125f214
> 
> Your questions about this central piece of networking code are worrying.
> 
>>
>> Aren't jiffies updated by the timer interrupt ? and thous even with
>> bh_disabled ?!?
> 
> Exactly my point : jiffie wont be updated in your code, since you block BH.

To be fair, jiffies get updated in hardirq and not softirq context. The
cond_resched_softirq not looking for pending softirqs is indeed a problem.

Thanks,
Hannes
