From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 07:40:25 -0700
Message-ID: <54412A59.7070508@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com> <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com> <54400C6C.7010405@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbaJQOkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2014 10:40:40 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/17/2014 02:11 AM, David Laight wrote:
> From: Alexander Duyck
> ...
>> Actually the likelihood of anything holding onto the 4K page for very
>> long doesn't seem to occur, at least from the drivers perspective.  It
>> is one of the reasons why I went for the page reuse approach rather than
>> just partitioning a single large page.  It allows us to avoid having to
>> call IOMMU map/unmap for the pages since the entire page is usually back
>> in the driver ownership before we need to reuse the portion given to the
>> stack.
> That is almost certainly true for most benchmarks, benchmark processes
> consume receive data.
> But what about real life situations?
>
> There must be some 'normal' workloads where receive data doesn't get consumed.
>
> 	David
>

Yes, but for workloads where receive data doesn't get consumed it is 
very unlikely that much receive data is generated.  As such from the 
device perspective the time the socket is holding the page is still not 
all that long as the descriptor ring is not being looped through that 
quickly.  The page has almost always been freed by the time we have 
processed our way through the full descriptor ring.

Thanks,

Alex
