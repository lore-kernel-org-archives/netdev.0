From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 22:43:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304162148520.1938-100000@l>
References: <20030416142802.E5912@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Manfred Spraul <manfred@colorfullife.com>,
   Catalin BOIE <util@deuroconsult.ro>, Tomas Szepe <szepe@pinerecords.com>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030416142802.E5912@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 16 Apr 2003, jamal wrote:

> > >This is a different problem from previous one posted.

	The problem should be the same. This 'lock bh + GFP_KERNEL'
BUG happens only when slab allocates pages, not on each kmalloc.

> > >Theres a small window (exposed given that you are provisioning a lot
> > >of qdiscs  and running traffic at the same time) that an incoming packet
> > >interupt will cause the BUG().

	This should not happen, may be you see another place that violates
the above rule? IMO, the only problem is that it is not good to
hold locks (including bh one) while using GFP_KERNEL.

Regards

--
Julian Anastasov <ja@ssi.bg>
