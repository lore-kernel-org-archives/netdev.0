From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 16:07:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202160738.439f9f0d.davem@redhat.com>
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

> 	Please review and edit if needed.

Thanks Julian, I will review your patch today.

But I want to mention something about this.  TOS checks
I think are pretty unreliable.

TOS has meaning within a network realm, right?  This means
that if we make a packet with TOS X, once it leaves our realm
the TOS value may be arbitrarily changed so that the TOS in
the packet has meaning within that new realm.

If a PMTU or other routing ICMP gets sent back to us after TOS changes
have been made, there is absolutely no way to reliably match the
routes properly for update.

Therefore TOS based routes cannot handle ICMP messages reliably
in the global internet.  In fact, it is possible and even likely
to apply an ICMP for the wrong TOS variant of a given route when
this TOS rewriting occurs.
