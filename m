From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Fri, 8 Jan 2016 11:01:49 +0100
Message-ID: <568F890D.70004@oracle.com>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
 <1452089115.8255.171.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman " <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	"\" hannes\"@stressinduktion.org " <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.ke
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452089115.8255.171.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/06/2016 03:05 PM, Eric Dumazet wrote:
> On Wed, 2016-01-06 at 14:16 +0100, Hans Westgaard Ry wrote:
>> Devices may have limits on the number of fragments in an skb they
>> support. Current codebase uses a constant as maximum for number of
>> fragments (MAX_SKB_FRAGS) one skb can hold and use.
>>
>> When enabling scatter/gather and running traffic with many small
>> messages the codebase uses the maximum number of fragments and thereby
>> violates the max for certain devices.
>>
>> An example of such a violation is when running IPoIB on a HCA
>> supporting 16 SGE on an architecture with 4K pagesize. The
>> MAX_SKB_FRAGS will be 17 (64K/4K+1) and because IPoIB adds yet another
>> segment we end up with send_requests with 18 SGE resulting in
>> kernel-panic.
>>
>> The patch allows the device to limit the maximum number fragments used
>> in one skb.
>>
>> The functionality corresponds to gso_max_size/gso_max_segs for gso.
> Unfortunately this is not the right place to fix this issue.
>
> Think about forwarding workloads, where the SKB is cooked by GRO engine.
>
> Anyway, local TCP stack uses 32KB page fragments, so typical skb has no
> more than 3 frags.
>
> Look at ndo_features_check(), where the problematic device driver can
> add its logic.
>
>
>
I've had a look at ndo_features_check and understand that I could supply 
my own
version of the routine, but I wasn't able to figure out how that would 
solve my problem.
As far as I can see the routine is not called in the part of code 
handling scatter/gather.
Could you help out with more info?


Hans
