From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Fri, 5 Dec 2003 12:43:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205124309.1490a2f4.davem@redhat.com>
References: <20031202163902.2deb43a7.davem@redhat.com>
	<Pine.LNX.4.44.0312032345190.1168-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312032345190.1168-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Dec 2003 00:03:20 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> - ip_rt_redirect now supports RTO_ONLINK
> 
> - ip_rt_frag_needed now supports RTO_ONLINK and all oif!=0

Let's discuss what RTO_ONLINK means :)

It means, "Do not route this packet".  It goes to the local subnet
and that's the end of the story.  Therefore there are no PMTU nor
redirects to handle when this TOS bit is set.

RTO_ONLINK is set by these two cases:

1) ARP 
2) RAW/UDP sockets when MSG_DONTROUTE is specified by the user.

So this patch still needs some work.
