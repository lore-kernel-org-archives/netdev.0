From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [patch -master] netfilter: xt_CT: checking for IS_ERR() instead
 of NULL
Date: Mon, 3 Aug 2015 13:34:58 -0700
Message-ID: <CANr6G5zw4NR5brVZ=AwXa9Gk0ALYDbPO=+LL-aRLJW=xsvdwJw@mail.gmail.com>
References: <20150727224228.GA10367@mwanda> <20150730115743.GA7077@salvia>
 <CANr6G5y1bO18L3bFuGs+=Dfszm0+voQtmz-u51nhGY0u5ebb-A@mail.gmail.com>
 <CANr6G5z7B1T0VCMQ1cVCpiDwJvOTNMfh0L3j6pDNVNHhmShAng@mail.gmail.com> <20150803202406.GA3339@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150803202406.GA3339@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3 August 2015 at 13:24, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Aug 03, 2015 at 11:30:16AM -0700, Joe Stringer wrote:
>> On 3 August 2015 at 11:29, Joe Stringer <joestringer@nicira.com> wrote:
>> > On 30 July 2015 at 04:57, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> >> On Tue, Jul 28, 2015 at 01:42:28AM +0300, Dan Carpenter wrote:
>> >>> We recently changed this from nf_conntrack_alloc() to nf_ct_tmpl_alloc()
>> >>> so the error handling needs to changed to check for NULL instead of
>> >>> IS_ERR().
>> >>>
>> >>> Fixes: 0838aa7fcfcd ('netfilter: fix netns dependencies with conntrack templates')
>> >>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> >>
>> >> Applied, thanks.
>> >>
>> >> I have also appended this chunk, since synproxy is also affected:
>> >>
>> >> --- a/net/netfilter/nf_synproxy_core.c
>> >> +++ b/net/netfilter/nf_synproxy_core.c
>> >> @@ -353,7 +353,7 @@ static int __net_init synproxy_net_init(struct net *net)
>> >>         int err = -ENOMEM;
>> >>
>> >>         ct = nf_ct_tmpl_alloc(net, 0, GFP_KERNEL);
>> >> -       if (IS_ERR(ct)) {
>> >> +       if (!ct) {
>> >>                 err = PTR_ERR(ct);
>> >>                 goto err1;
>> >>         }
>> >
>> > Does PTR_ERR() implicitly interpret NULL as -ENOMEM? Seems like the
>> > fix applied here is a little different from the xt_CT fix.
>>
>> Just saw the initialization of err now, but this would be overridden
>> within the error checking statement.
>
> Right, I noticed before pushing out this change, the final applied
> patch is here:
>
> http://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/commit/?id=1a727c63612fc582370cf3dc01239d3d239743b5
>
> Let me know if you still have any concern, thanks Joe.

Looks fine. Apologies for the noise.
