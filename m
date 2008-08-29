From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Fri, 29 Aug 2008 08:43:18 -0700
Message-ID: <20080829084318.04f0fad8@extreme>
References: <20080827.201020.17601834.davem@davemloft.net>
	<200808282225.57535.denys@visp.net.lb>
	<48B6FE6C.4080905@cosmosbay.com>
	<200808282255.29640.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andi Kleen <andi@firstfloor.org>,
	Joe Malicki <jmalicki@metacarta.com>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756898AbYH2Pnn@vger.kernel.org>
In-Reply-To: <200808282255.29640.denys@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Aug 2008 22:55:29 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> On Thursday 28 August 2008, Eric Dumazet wrote:
> > OK, please try oprofile with call graph analysis.
> I did already. Even because most of programs (except ripd/zebra) can be 
> killed, and i kill them, it doesn't change almost anything.
> 
> it seems heavy things causing instability:
> 
> 1)HTB (resolution can be lowered to improve performance, i will try Jarek 
> patch soon)

If you are doing HTB it also calls clock to get timing information.
Each packet dequeue in htb calls psched_get_time() and that becomes
another call nano-second real time clock.

If your embedded processor has really expensive clock, you probably
just want to provide an alternative cheaper time source with less
resolution.
