From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Fri, 5 Nov 2004 16:36:50 -0800
Message-ID: <20041105163650.19a487d6.davem@davemloft.net>
References: <418B4C7C.8000402@crocom.com.pl>
	<20041105115430.GP19714@rei.reeler.org>
	<418B4C7C.8000402@crocom.com.pl>
	<20041105141640.GQ19714@rei.reeler.org>
	<418BA66A.60804@trash.net>
	<20041105163951.GY12289@postel.suug.ch>
	<418BB7D2.6060908@trash.net>
	<20041105175812.GZ12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041105175812.GZ12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Nov 2004 18:58:12 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> I was irritated by the TCQ_F_BUILTIN check in __qdisc_destroy. None
> of the code in __qdisc_destroy should be applied to a builtin qdisc
> or am I missing something?
> 
> The patch below prevents builtin qdiscs from being destroyed and
> fixes a refcnt underflow whould lead to a bogus list unlinking
> and dev_put.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I'll apply this, along with the builting qdisc list initializer
change too just for cleanliness, thanks Thomas.

Ingo Molnar noticed this refcount underflow condition in qdisc_destroy()
a couple weeks ago.  At the time I didn't connect it to being a builting
qdisc issue.  Now we know the true cause.

Thanks again.
