From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 06/13] QLogic VNIC: IB core stack
	interaction
Date: Tue, 13 May 2008 13:40:52 -0700
Message-ID: <adafxsmj5t7.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171855.31725.89658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080430171855.31725.89658.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:48:55 +0530")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +#include <rdma/ib_cache.h>

 > +	ret = ib_find_cached_pkey(viport_config->ibdev,
 > +				  viport_config->port,
 > +				  be16_to_cpu(viport_config->path_info.path.
 > +					      pkey),
 > +				  &attr->pkey_index);

I think this can just be replaced with ib_find_pkey()... there is a call
to kmalloc(... GFP_KERNEL) just a couple of lines about, so you are in a
context where sleeping is allowed.  As I said before we want to get rid
of the caching infrastructure so please don't add new users.
