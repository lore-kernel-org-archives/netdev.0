From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch 2.6.11] bonding: avoid tx balance for IGMP (alb/tlb mode)
Date: Tue, 15 Mar 2005 17:03:01 -0800
Message-ID: <200503160103.j2G132YO016999@death.nxdomain.ibm.com>
References: <rick.jones2@hp.com>
Cc: "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org,
        ctindel@users.sourceforge.net, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, jgarzik@pobox.com
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: Message from Rick Jones <rick.jones2@hp.com>
   of "Tue, 15 Mar 2005 16:52:14 PST." <4237833E.9080809@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:

><blank> treats IGMP packets the same as all other non-broadcast traffic (i.e. it
>will attempt to load balance). This switch behavior seems rather odd in an
>aggregated case, given the fact that most traffic (except broadcast packets)
>will be load balanced by the partner device. In addition, the switch (in
>theory) is suppose to treat the aggregated switch ports as 1 logical port
>and therefore it should allow IGMP packets to be received back on any port
>in the logical aggregation.
>
>IMO, the switch behavior in this case seems questionable.

	This patch only applies to the bonding balance-alb/tlb modes,
which do not require the switch to be configured for aggregation.  Since
the switch has no explicit knowledge that the links are being
aggregated, it seems reasonable for it to be confused by what it gets in
the described case.

	I haven't tested the patch, but conceptually the problem John
described in his original mail sounds plausible, as does the fix for it.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
