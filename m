From: Andy Grover <andy.grover@oracle.com>
Subject: [ofa-general] Re: [PATCH 20/21] RDS: Kconfig and Makefile
Date: Wed, 28 Jan 2009 18:19:42 -0800
Message-ID: <4981123E.2060406@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>	<1233022678-9259-21-git-send-email-andy.grover@oracle.com>
	<adazlhbt4ta.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adazlhbt4ta.fsf@cisco.com>
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

Roland Dreier wrote:
>  > +obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/rds/
> 
> Typo for ..._RDS

Whups. :)

>  > +config INFINIBAND_RDS_DEBUG
>  > +        bool "Debugging messages"
>  > +	depends on INFINIBAND_RDS
>  > +        default n
> 
> No way to enable this?  Disabled by default?
> 
> You really want debugging messages to be built by default and controlled
> at runtime ... otherwise debugging end-user installations is a pain
> (they just install what the distro gives them, and it's very hard for
> them to rebuild just to enable debugging).

So the solution is just to base debug message output on a variable,
instead of a config option? RDS actually does do this a little already,
so converting totally isn't hard. I hadn't seen mention this was
preferable -- indeed, tons of drivers and subsystems have options for
compile-time debug statements, should these be converted?

>  > +ib_rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
>  > +			recv.o send.o stats.o sysctl.o threads.o transport.o \
>  > +			loop.o page.o rdma.o
>  > +
>  > +ib_rds-y += ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
>  > +			ib_sysctl.o ib_rdma.o
> 
> a very strange way to write an assignment statement...

RDS is implemented as a core sockets layer and then a transport layer.
IB is currently the only transport so I thought it made sense to just
compile them together, but once there are >1 then RDS's IB support could
be broken out into its own module.

Regards -- Andy
