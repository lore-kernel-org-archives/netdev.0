From: "David S. Miller" <davem@redhat.com>
Subject: Re: NAT before IPsec with 2.6
Date: Wed, 28 Jan 2004 11:38:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128113825.769fd89c.davem@redhat.com>
References: <20040124082252.GA19035@alpha.home.local>
	<Pine.LNX.4.44.0401241015470.32723-100000@filer.marasystems.com>
	<20040124092721.GA19140@alpha.home.local>
	<20040127103917.GC11761@sunbeam.de.gnumonks.org>
	<20040127132725.GA14685@openoffice.nl>
	<pan.2004.01.27.21.13.32.754125@dungeon.inka.de>
	<20040128085831.GM11761@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: aj@dungeon.inka.de, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040128085831.GM11761@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 09:58:31 +0100
Harald Welte <laforge@netfilter.org> wrote:

> No, we don't achieve this by manipulating the routing code, but by
> placing the respective hooks in ah{4,6}.c and esp{4,6}.c
> {ah,esp}_output() function respectively. We also need to (again) reset
> the skb->nfct and drop the conntrack reference again.

Why not just do this right when we pop into the dst_output() call
in ip_output.c  This way we don't have to add all of this stuff
for every new encapsulator we ever implement.

Maybe not like this precisely, but something like it.
