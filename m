From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 16:38:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829163821.2a4239df.davem@davemloft.net>
References: <412A8FB5.4080700@trash.net>
	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
	<20040828231529.051a73cc.davem@davemloft.net>
	<4132303C.2060807@trash.net>
	<20040829125708.5aa70469.davem@davemloft.net>
	<4132516E.7080805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4132516E.7080805@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Aug 2004 23:58:06 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Before I post the patch, 2.4 seems to be
> missing this patch, do you already have it queued or should I send
> a 2.4 version first ?
> 
> ChangeSet@1.1853, 2004-08-18 14:28:05-07:00, davem@nuts.davemloft.net
>   [IPV4]: Fix theoretical loop on SMP in ip_evictor().

I pushed this off to Marcelo, he just didn't pull from my
tree yet, which is at:

	bk://kernel.bkbits.net/davem/net-2.4

Where you'll find those fixes as:

ChangeSet@1.1498.1.2, 2004-08-18 14:26:09-07:00, davem@nuts.davemloft.net
  [IPV4]: Fix theoretical loop on SMP in ip_evictor().
  
  Snapshot the amount of work to do, and just do it.
  In this way we avoid a theoretical loop whereby
  one cpu sits in ip_evictor() tossing fragments
  while another keeps adding a fragment just as we
  bring ip_frag_mem  down below the low threshold.
  
  Signed-off-by: David S. Miller <davem@redhat.com>

ChangeSet@1.1498.1.3, 2004-08-18 14:31:35-07:00, davem@nuts.davemloft.net
  [IPV6]: ip6_evictor() has same problem as ip_evictor().
  
  Signed-off-by: David S. Miller <davem@redhat.com>
