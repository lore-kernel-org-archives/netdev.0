From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 14:40:26 -0700
Message-ID: <1413495626.28798.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543FFC03.1060207@redhat.com>
	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54400C6C.7010405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <54400C6C.7010405@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-10-16 at 11:20 -0700, Alexander Duyck wrote:

> My concern would be that we are off by a factor of 2 and prematurely 
> collapse the TCP too soon with this change. 

That is the opposite actually. We can consume 4K but we pretend we
consume 2K in some worst cases.

>  For example if you are 
> looking at a socket that is holding pages for a long period of time 
> there would be a good chance of it ending up with both halves of the 
> page.  In this case is it fair to charge it for 8K or memory use when in 
> reality it is only using 4K?

Its better to collapse too soon than too late.

If you want to avoid collapses because one host has plenty of memory,
all you need to do is increase tcp_rmem.

Why are you referring to 8K ? PAGE_SIZE is 4K


