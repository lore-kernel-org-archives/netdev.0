From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 12:36:21 +0100
Message-ID: <56B1E635.8020707@stressinduktion.org>
References: <568F87AC.60405@oracle.com>
 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
 <20160203112550.GB28003@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
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
	=?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?UTF-8?Q?H=c3=a5kon_Bugge?= <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160203112550.GB28003@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.02.2016 12:25, Herbert Xu wrote:
> On Wed, Feb 03, 2016 at 09:26:57AM +0100, Hans Westgaard Ry wrote:
>> Devices may have limits on the number of fragments in an skb they su=
pport.
>> Current codebase uses a constant as maximum for number of fragments =
one
>> skb can hold and use.
>> When enabling scatter/gather and running traffic with many small mes=
sages
>> the codebase uses the maximum number of fragments and may thereby vi=
olate
>> the max for certain devices.
>> The patch introduces a global variable as max number of fragments.
>>
>> Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
>> Reviewed-by: H=C3=A5kon Bugge <haakon.bugge@oracle.com>
>
> I have to say this seems rather dirty.  I mean if taken to the
> extreme wouldn't this mean that we should disable frags altogether
> if some NIC can't handle them at all?
>
> Someone suggested earlier to partially linearise the skb, why
> couldn't we do that? IOW let's handle this craziness in the crazy
> drivers and not in the general stack.

Agreed that it feels like a hack, but a rather simple one. I would
consider this to be just a performance improvement. We certainly need
a slow-path when virtio drivers submit gso packets to the stack (and
already discussed with Hans). The sysctl can't help here. But without
the sysctl the packets would constantly hit the slow-path in case of
e.g. IPoIB and that would also be rather bad.

Thanks,
Hannes
