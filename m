From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 12:38:44 -0700
Message-ID: <54417044.5090602@gmail.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com>	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <54400C6C.7010405@redhat.com>	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>	 <54412A59.707050
 8@redhat.com>	 <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <54415FEA.5000705@redhat.com> <1413572539.25949.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413572539.25949.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2014 12:02 PM, Eric Dumazet wrote:
> On Fri, 2014-10-17 at 11:28 -0700, Alexander Duyck wrote:
>
>> So long as it doesn't impact performance significantly I am fine with 
>> it.  My concern is that you are bringing up issues that none of the 
>> customers were brining up when I was at Intel, and the fixes you are 
>> proposing are likely to result in customers seeing things they will 
>> report as issues.
> We regularly hit these issues at Google.
>
> We have memory containers, and we detect quite easily if some layer is
> lying, because we cant afford having 20% of headroom on our servers.

Data is useful here.  If you can give enough data about the setup to
reproduce it then we can actually start looking at fixing it.  Otherwise
it is just your anecdotal data versus mine.

> I am not claiming IGB is the only offender.
>
> I am sorry if you believe it was an attack on IGB, or any network
> driver.

My concern is that igb is guilty of being off by at most a factor of 2. 
What about the drivers and implementations that are off by possibly much
larger values?  I'd be much more interested in this if there was data to
back up your position.  Right now it is mostly just conjecture and my
concern is that this type of change may cause more harm than good.

> truesize should really be the thing that protects us from OOM,
> and apparently driver authors hitting TCP performance problems
> thinks it is better to simply let TCP do no garbage collection.

One key point to keep in mind is that the igb performance should take a
pretty hard hit if pages aren't being freed.  The overhead difference
between the page reuse path vs non-page reuse is pretty significant.  If
this is a scenerio you are actually seeing this would be of interest.

> It seems that nobody cares or even understand what I am saying,
> so I should probably not care and suggest Google to buy PetaBytes of
> memory, right ?

That's not what I am saying, but there is a trade-off we always have to
take into account.  Cutting memory overhead will likely have an impact
on performance.  I would like to make the best informed trade-off in
that regard rather than just assuming worst case always for the driver.

Thanks,

Alex
