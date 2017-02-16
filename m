From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH rfc 0/4] Introduce a new helper for parsing ipv[4|6]:port to socket address
Date: Thu, 16 Feb 2017 12:50:25 -0500
Message-ID: <AD117189-9D24-4C5C-9751-9EA6B27575B1@oracle.com>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-nvme@lists.infradead.org,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        target-devel@vger.kernel.org, netdev@vger.kernel.org
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Feb 16, 2017, at 12:43 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> We have some places in the stack that support ipv4 and ipv6. In
> some cases the user configuration does not reveal which
> address family is given and needs to be parsed from the input string.
> 
> Given that the user-input varies between subsystems, some processing
> is required from the call-site to separate address and port strings.
> 
> As a side-effect, this set adds ipv6 support for nvme over fabrics.
> I also converted iscsi target and plan to convert nfs/cifs next but
> wanted to get some feedback before doing that.

At least NFS/RDMA already supports IPv6. You might not need many
changes there, but I'll hold off on further comments.


> patch #1 is based off roland's patch:
> http://lists.infradead.org/pipermail/linux-nvme/2016-August/005600.html
> 
> Sagi Grimberg (4):
>  net/utils: generic inet_pton_with_scope helper
>  nvmet-rdma: use generic inet_pton_with_scope
>  nvme-rdma: use inet_pton_with_scope helper
>  iscsi-target: use generic inet_pton_with_scope
> 
> drivers/nvme/host/rdma.c                     | 48 ++++-----------
> drivers/nvme/target/rdma.c                   | 42 +++++++++----
> drivers/target/iscsi/iscsi_target_configfs.c | 46 ++++----------
> include/linux/inet.h                         |  6 ++
> net/core/utils.c                             | 91 ++++++++++++++++++++++++++++
> 5 files changed, 151 insertions(+), 82 deletions(-)
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
