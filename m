From: "David S. Miller" <davem@redhat.com>
Subject: Re: Dump of TCP hang in established state
Date: Thu, 29 May 2003 14:52:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.145246.23019115.davem@redhat.com>
References: <1054217010.757.39.camel@tux.rsn.bth.se>
	<1054238230.709.1.camel@tux.rsn.bth.se>
	<3ED68090.5040903@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3ED68090.5040903@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu, 29 May 2003 14:50:08 -0700

   Martin Josefsson wrote:
   
   > I've just tested 2.5-bk and I can still reproduce it.
   > The wording of my mail might have been a bit wrong, I don't see complete
   > hangs, just ~2 minute stalls in ESTABLISHED state and then it continues
   > like nothing happened.
   > 
   
   This actually addresses a situation of memory corruption
   and illegal reference panics, correct?

It prevents TCP input from "reading" bogus memory when comparing
time_wait buckets to the saddr/sport/daddr/dport of an incoming
packet.

By bogus memory I mean it's some large offset from the base of the
struct tcp_tw_bucket structure, past it's end.
