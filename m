From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: TProxy, 2.4 Kernel and NetFilter
Date: Wed, 11 Feb 2004 08:49:33 +0100 (CET)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Pine.LNX.4.44.0402110840470.23130-100000@filer.marasystems.com>
References: <20040209075644.11922.qmail@web25110.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@lists.netfilter.org, <netdev@oss.sgi.com>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: =?iso-8859-1?q?Jambunathan=20Kalyanasundaram?= <k_jambunathan@yahoo.co.uk>
In-Reply-To: <20040209075644.11922.qmail@web25110.mail.ukl.yahoo.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2004, Jambunathan Kalyanasundaram wrote:

> 2) But if I am not really interested in the overheads
> imposed by the NetFilter, the only option is to patch
> the Linux kernel with Balazs Scheidler's patch.

Not sure this has less overhead.

> If I don't like something as heavyweight as Netfilter
> and something that is as  "non standard" as patching
> the kernel, are there any ways out ? 

Yes, by configuring the client to use the proxy.

> Also are there any existing NetFilter modules that
> work on a standard, unpatched kerenel that allow proxy
> to talk to the web server as though it's the web
> browser ( source address spoofing ) ?

Depends on your environment and the proxy.

First requirement is that the proxy is running inline on a gateway in the
data path between the webserver and the client. If this is not the case 
then forget about it.

If it is a normal Internet proxy environment where the number of clients 
are limited, and the proxy supports per-user selection of the outgoing 
address (Squid does) then it is possible with the help of NAT.

1. Set up as many IP aliases on the proxy server as you have clients. Use
one of the unassigned networks.

2. Configure the proxy to use one IP alias per client IP address.

3. Configure iptables NAT rules in OUTPUT to NAT these IP aliases back to
the client IP address.


If it is a reverse proxy or other environment where the client addresses 
are not limited then this obviously can not be done and you must use the 
tproxy patch.

Regards
Henrik
