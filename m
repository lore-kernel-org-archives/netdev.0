From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 01:22:02 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.012202.68055632.davem@redhat.com>
References: <20030609065211.GB20613@netnation.com>
	<20030608.235622.38700262.davem@redhat.com>
	<20030609081803.GF20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030609081803.GF20613@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 9 Jun 2003 01:18:03 -0700

   On Sun, Jun 08, 2003 at 11:56:22PM -0700, David S. Miller wrote:
   
   > +	if (cand) {
   > +		*candp = cand->u.rt_next;
   > +		rt_free(cand);
   >  	}
   
   Hmm...It looks like this is still freeing the entry.. Is it possible to
   recycle the dst without reallocating it?
   
Yes, can you test the patch I just sent you?  We can modify that
to recycle easily instead of freeing.

Well... one problem is that in 2.5.x we have to kill off entries using
RCU so such recycling may not be so easy there.

   This is with a routing table of 300,000 entries (though only one prefix)
   and with your hash fix patch.  ip_route_input is still highest, but
   dst_alloc is an obvious second.  ip_route_input is actually always the
   highest (excluding the IRQ handling stuff), and doesn't seem to change at
   all based on routing table size.

We spend a decent amount of time mucking with fib rules, turning
off multiple-tables support would kill that, although I suspect
you're actually using that :)
