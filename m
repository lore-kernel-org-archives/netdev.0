From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 16:39:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202163902.2deb43a7.davem@redhat.com>
References: <20031201155005.1c515793.davem@redhat.com>
	<Pine.LNX.4.44.0312030121130.1237-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312030121130.1237-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Dec 2003 01:40:06 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> - ip_rt_frag_needed now provides interface index

I disagree with this.

There is no connection between the route (and thus output
device) we used to send a packet and the interface on which
an ICMP for that packet comes back upon.  Think assymetric
routes.

You changes mean that for routes with specific output interfaces,
we will ignore ICMPs for those routes that arrive on other interfaces
due to assymetric routing.

Why don't you create a seperate patch that just has the TOS masking
changes?  That's much less controversial and thus something I'm likely
to apply.
