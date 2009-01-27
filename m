From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH 0/21] Reliable Datagram Sockets (RDS)
Date: Tue, 27 Jan 2009 09:34:57 -0600
Message-ID: <497F29A1.60003@opengridcomputing.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
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

Hey Andy,

Why didn't you include the iWARP transport as well?


Andy Grover wrote:
> Hi Roland,
>
> This patchset adds support for RDS as an Infiniband ULP. RDS is an
> Oracle-originated protocol used to send IPC datagrams (up to 1MB) reliably,
> and is used currently in Oracle RAC and Exadata products. It's lived
> in OFED for 2+ years and I think it's time to get it upstream -- most
> likely into your -next tree for .30, but if it snuck into .29 via the
> "new code merge-window exception" then even better.
>
> I've run checkpatch & sparse to clean up as many issues as possible so
> what remains are really the design peculiarities (aka warts) that arise
> from being a protocol designed by one company for a single critical
> application. I think upstreaming this code is the first step towards
> working out those issues, and making the end result available to a wider
> audience.
>
> Also available for review at:
> git://git.openfabrics.org/~agrover/ofed_1_4/linux-2.6 for-roland
>
> Thoughts? shortlog follows.
>
> Thanks -- Regards -- Andy
>
> Andy Grover (21):
>       RDS: Socket interface
>       RDS: Main header file
>       RDS: Congestion-handling code
>       RDS: Transport code
>       RDS: Info and stats
>       RDS: Connection handling
>       RDS: loopback
>       RDS: sysctls
>       RDS: Message parsing
>       RDS: send.c
>       RDS: recv.c
>       RDS: RDMA support
>       RDS/IB: Infiniband transport
>       RDS/IB: Ring-handling code.
>       RDS/IB: Implement RDMA ops using FMRs
>       RDS/IB: Implement IB-specific datagram send.
>       RDS/IB: Receive datagrams via IB
>       RDS/IB: Stats and sysctls
>       RDS: Documentation
>       RDS: Kconfig and Makefile
>       RDS: Add AF and PF #defines for RDS sockets
>
>  Documentation/networking/rds.txt        |  356 +++++++++++
>  drivers/infiniband/Kconfig              |    2 +
>  drivers/infiniband/Makefile             |    1 +
>  drivers/infiniband/ulp/rds/Kconfig      |   13 +
>  drivers/infiniband/ulp/rds/Makefile     |   13 +
>  drivers/infiniband/ulp/rds/af_rds.c     |  677 +++++++++++++++++++++
>  drivers/infiniband/ulp/rds/bind.c       |  202 +++++++
>  drivers/infiniband/ulp/rds/cong.c       |  424 +++++++++++++
>  drivers/infiniband/ulp/rds/connection.c |  501 +++++++++++++++
>  drivers/infiniband/ulp/rds/ib.c         |  312 ++++++++++
>  drivers/infiniband/ulp/rds/ib.h         |  358 +++++++++++
>  drivers/infiniband/ulp/rds/ib_cm.c      |  882
> +++++++++++++++++++++++++++
>  drivers/infiniband/ulp/rds/ib_rdma.c    |  641 ++++++++++++++++++++
>  drivers/infiniband/ulp/rds/ib_recv.c    |  894
> +++++++++++++++++++++++++++
>  drivers/infiniband/ulp/rds/ib_ring.c    |  168 +++++
>  drivers/infiniband/ulp/rds/ib_send.c    |  852
> ++++++++++++++++++++++++++
>  drivers/infiniband/ulp/rds/ib_stats.c   |   95 +++
>  drivers/infiniband/ulp/rds/ib_sysctl.c  |  137 +++++
>  drivers/infiniband/ulp/rds/info.c       |  243 ++++++++
>  drivers/infiniband/ulp/rds/info.h       |   43 ++
>  drivers/infiniband/ulp/rds/loop.c       |  189 ++++++
>  drivers/infiniband/ulp/rds/loop.h       |    9 +
>  drivers/infiniband/ulp/rds/message.c    |  414 +++++++++++++
>  drivers/infiniband/ulp/rds/page.c       |  222 +++++++
>  drivers/infiniband/ulp/rds/rdma.c       |  682 +++++++++++++++++++++
>  drivers/infiniband/ulp/rds/rdma.h       |   84 +++
>  drivers/infiniband/ulp/rds/rds.h        |  763 +++++++++++++++++++++++
>  drivers/infiniband/ulp/rds/rds_rdma.h   |  245 ++++++++
>  drivers/infiniband/ulp/rds/recv.c       |  550 +++++++++++++++++
>  drivers/infiniband/ulp/rds/send.c       | 1006
> +++++++++++++++++++++++++++++++
>  drivers/infiniband/ulp/rds/stats.c      |  150 +++++
>  drivers/infiniband/ulp/rds/sysctl.c     |  164 +++++
>  drivers/infiniband/ulp/rds/threads.c    |  273 +++++++++
>  drivers/infiniband/ulp/rds/transport.c  |  134 ++++
>  include/linux/socket.h                  |    4 +-
>  35 files changed, 11702 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/networking/rds.txt
>  create mode 100644 drivers/infiniband/ulp/rds/Kconfig
>  create mode 100644 drivers/infiniband/ulp/rds/Makefile
>  create mode 100644 drivers/infiniband/ulp/rds/af_rds.c
>  create mode 100644 drivers/infiniband/ulp/rds/bind.c
>  create mode 100644 drivers/infiniband/ulp/rds/cong.c
>  create mode 100644 drivers/infiniband/ulp/rds/connection.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib.h
>  create mode 100644 drivers/infiniband/ulp/rds/ib_cm.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_rdma.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_recv.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_ring.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_send.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_stats.c
>  create mode 100644 drivers/infiniband/ulp/rds/ib_sysctl.c
>  create mode 100644 drivers/infiniband/ulp/rds/info.c
>  create mode 100644 drivers/infiniband/ulp/rds/info.h
>  create mode 100644 drivers/infiniband/ulp/rds/loop.c
>  create mode 100644 drivers/infiniband/ulp/rds/loop.h
>  create mode 100644 drivers/infiniband/ulp/rds/message.c
>  create mode 100644 drivers/infiniband/ulp/rds/page.c
>  create mode 100644 drivers/infiniband/ulp/rds/rdma.c
>  create mode 100644 drivers/infiniband/ulp/rds/rdma.h
>  create mode 100644 drivers/infiniband/ulp/rds/rds.h
>  create mode 100644 drivers/infiniband/ulp/rds/rds_rdma.h
>  create mode 100644 drivers/infiniband/ulp/rds/recv.c
>  create mode 100644 drivers/infiniband/ulp/rds/send.c
>  create mode 100644 drivers/infiniband/ulp/rds/stats.c
>  create mode 100644 drivers/infiniband/ulp/rds/sysctl.c
>  create mode 100644 drivers/infiniband/ulp/rds/threads.c
>  create mode 100644 drivers/infiniband/ulp/rds/transport.c
>
> end
>
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
>   
