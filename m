From: "David S. Miller" <davem@redhat.com>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 10:27:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819102753.408858e0.davem@redhat.com>
References: <200408190721.QAA02944@toshiba.co.jp>
	<20040819094401.GY3921@sunbeam.de.gnumonks.org>
	<20040819071750.67f0e924.davem@redhat.com>
	<20040819170040.GW3921@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net, kadlec@blackhole.kfki.hu,
        kisza@securityaudit.hu, netfilter-devel@lists.netfilter.org,
        usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040819170040.GW3921@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 19:00:40 +0200
Harald Welte <laforge@netfilter.org> wrote:

> can imagine a case where parts of the header up and including the tcp
> options could be non-linear.

A driver could do this, by putting all receive SKB data into
pages.

I am not aware of any that currently do this.

Such a driver would have to be very careful, as things like
the ethernet header parsing code on receive is not ready
for such things.  Things like pskb_may_pull() calls would
need to be added to that code for this to work.
