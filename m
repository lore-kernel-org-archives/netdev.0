From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 10:24:20 -0800
Message-ID: <CAKgT0UeueE5EhLu0-8jcr0+su81sOV_qCpb-KGRf7q4EKsw1QQ@mail.gmail.com>
References: <568F87AC.60405@oracle.com>
	<1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	<CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
	<1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
	<1454522077.7627.264.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?UTF-8?B?SMOla29uIEJ1Z2dl?= <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454522077.7627.264.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 9:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-02-03 at 09:43 -0800, Alexander Duyck wrote:
>
>> Read the history.  I still say it is best if we don't accept a partial
>> solution.  If we are going to introduce the sysctl as a core item it
>> should function as a core item and not as something that belongs to
>> TCP only.
>
>
> But this patch is the base, adding both the core sysctl and its first
> usage.
>
> Do we really need to split it in 2 patches ? Really ?
>
> The goal is to use it in all skb providers were it might be a
> performance gain, once they are identified.

That is what I thought.  So why are we trying to sell this as a core
change then.  All I am asking for is the sysctl to be moved and
renamed since based on all of your descriptions this clearly only
impacts TCP.

> Your points were already raised and will be addressed, by either me or
> you. And maybe others.

Please don't sign me up for work I didn't volunteer for.  I already
have enough broken code to try and fix.  I'm pretty sure I need to go
in and fix the gso_max_size code for starters.

If this is only meant to be a performance modification and is only
really targeted at TCP TSO/GRO then all I ask is that we use a name
like tcp_max_gso_frags and relocate the sysctl to the TCP section.
Otherwise if we are actually going to try to scope this out on a wider
level and limit all frags which is what the name implies then the
patch set needs to make a better attempt at covering all cases where
it may apply.

- Alex
