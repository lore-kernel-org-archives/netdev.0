From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Mon, 16 Nov 2015 20:55:26 -0500 (EST)
Message-ID: <20151116.205526.851300695363409790.davem@davemloft.net>
References: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151115.183703.577812988592183622.davem@davemloft.net>
	<CAP=VYLoykaLLJgv00qnm7D=EfcSdF7F-9vop+Nsv2Q8a28YO0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLoykaLLJgv00qnm7D=EfcSdF7F-9vop+Nsv2Q8a28YO0w@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 16 Nov 2015 20:45:25 -0500

> Just a heads up that this breaks all arm64 builds in linux-next from
> Monday; bisect says:
> 
> 00fd38d938db3f1ab1c486549afc450cb7e751b1 is the first bad commit
> commit 00fd38d938db3f1ab1c486549afc450cb7e751b1
> Author: Eric Dumazet
> <edumazet@google.com>http://kisskb.ellerman.id.au/kisskb/buildresult/12548450/
> Date:   Thu Nov 12 08:43:18 2015 -0800
> 
>     tcp: ensure proper barriers in lockless contexts
> 
> Here is one of the linux-next fails:
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/12548450/

Thanks for the report Paul.

I think Eric's patch is correct.  I see what ARM is trying to do here,
but it really has to accomodate const arguments to smp_load_acquire().
