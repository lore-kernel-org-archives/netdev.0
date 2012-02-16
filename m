From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [PATCH] atl1c: dont use highprio tx queue
Date: Thu, 16 Feb 2012 07:36:09 -0500
Message-ID: <CA+5PVA74bejZhPxUAFHaeHLB0NBd7PCRc1sQvmSY7QdmarCWEw@mail.gmail.com>
References: <1329063403.1449.14.camel@localhost.localdomain>
	<CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	<1329204997.24837.15.camel@edumazet-laptop>
	<1329366846.5646.1.camel@edumazet-laptop>
	<C6B7BB6C-D1B8-4454-A2B2-558FCA5B0BBD@m3y3r.de>
	<1329373082.5646.9.camel@edumazet-laptop>
	<21390AB8-BD9B-44D7-B2CE-B20AF7605CE7@m3y3r.de>
	<1329374591.5646.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Meyer <thomas@m3y3r.de>, David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329374591.5646.23.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 1:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> This driver attempts to use two TX rings but lacks proper support :
>
> 1) IRQ handler only takes care of TX completion on first TX ring
> 2) the stop/start logic uses the legacy functions (for non multiqueue
> drivers)
>
> This means all packets witk skb mark set to 1 are sent through high
> queue but are never cleaned and queue eventualy fills and block the
> device, triggering the infamous "NETDEV WATCHDOG" message.
>
> Lets use a single TX ring to fix the problem, this driver is not a real
> multiqueue one yet.
>
> Minimal fix for stable kernels.
>
> Reported-by: Thomas Meyer <thomas@m3y3r.de>
> Tested-by: Thomas Meyer <thomas@m3y3r.de>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jay Cliburn <jcliburn@gmail.com>
> Cc: Chris Snook <chris.snook@gmail.com>

As I think David handles netdev patches a bit differently for stable releases,
I'd like to suggest this get included in the next batch for the 3.2 kernel.
We've been seeing the bug this patch fixes in Fedora for quite a while now.

josh
