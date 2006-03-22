From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 6/6 v2] IB: userspace support for RDMA
	connection manager
Date: Tue, 21 Mar 2006 17:40:54 -0800
Message-ID: <adawten6yu1.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG0000000f@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX4011XvpFVjCRG0000000f@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Mon, 6 Mar 2006 15:41:14 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

I added this patch to the rdma_cm branch in my git tree.  When I was
doing that, I noticed that it builds rdma_ucm.ko unconditionally.  It
seems that we want this to depend on CONFIG_INFINIBAND_USER_ACCESS,
since that controls ib_uverbs.ko and ib_ucm.ko.

To do this I rejiggered the Kconfig and Makefile changes I made
before.  I made CONFIG_INFINIBAND_ADDR_TRANS into a bool (instead of a
tristate), so that it's 'y' if INFINIBAND and INET are on, and made
the top of the Makefile look like:

infiniband-$(CONFIG_INFINIBAND_ADDR_TRANS)	:= ib_addr.o rdma_cm.o
user_access-$(CONFIG_INFINIBAND_ADDR_TRANS)	:= rdma_ucm.o

obj-$(CONFIG_INFINIBAND) +=		ib_core.o ib_mad.o ib_sa.o \
					ib_cm.o $(infiniband-y)
obj-$(CONFIG_INFINIBAND_USER_MAD) +=	ib_umad.o
obj-$(CONFIG_INFINIBAND_USER_ACCESS) +=	ib_uverbs.o ib_ucm.o $(user_access-y)

I'm pretty sure this does exactly what we want.

 - R.
