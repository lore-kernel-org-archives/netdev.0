From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 07:45:51 -0700
Message-ID: <CANn89iJOEpoYKS+=VU-zVEcs2geRF07nii_VdwCX1anHmhoodQ@mail.gmail.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	<1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	<90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	<CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	<94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	<1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462960104.4444.37.camel@redhat.com>
	<1462972112.23934.139.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462977516.4444.73.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
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
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462977516.4444.73.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 11, 2016 at 7:38 AM, Paolo Abeni <pabeni@redhat.com> wrote:

> Uh, we have likely the same issue in the net_rx_action() function, which
> also execute with bh disabled and check for jiffies changes even on
> single core hosts ?!?

That is why we have a loop break after netdev_budget=300 packets.
And a sysctl to eventually tune this.

Same issue for softirq handler, look at commit
34376a50fb1fa095b9d0636fa41ed2e73125f214

Your questions about this central piece of networking code are worrying.

>
> Aren't jiffies updated by the timer interrupt ? and thous even with
> bh_disabled ?!?

Exactly my point : jiffie wont be updated in your code, since you block BH.
