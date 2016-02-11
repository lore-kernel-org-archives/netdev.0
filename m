From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3] openvswitch: allow management from inside user namespaces
Date: Thu, 11 Feb 2016 10:10:59 +0100
Message-ID: <CAOrHB_CLkirGUf4r=0pyJppaKgbV7nm8u5guXcM=sdup2YJCnA@mail.gmail.com>
References: <1454689252-18749-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org,
	Eric Biederman <ebiederm@xmission.com>,
	Justin Pettit <jpettit@nicira.com>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454689252-18749-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 5, 2016 at 5:20 PM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> Operations with the GENL_ADMIN_PERM flag fail permissions checks because
> this flag means we call netlink_capable, which uses the init user ns.
>
> Instead, let's introduce a new flag, GENL_UNS_ADMIN_PERM for operations
> which should be allowed inside a user namespace.
>
> The motivation for this is to be able to run openvswitch in unprivileged
> containers. I've tested this and it seems to work, but I really have no
> idea about the security consequences of this patch, so thoughts would be
> much appreciated.
>
> v2: use the GENL_UNS_ADMIN_PERM flag instead of a check in each function
> v3: use separate ifs for UNS_ADMIN_PERM and ADMIN_PERM, instead of one
>     massive one
>
> Reported-by: James Page <james.page@canonical.com>
> Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> CC: Eric Biederman <ebiederm@xmission.com>
> CC: Pravin Shelar <pshelar@ovn.org>
> CC: Justin Pettit <jpettit@nicira.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  include/uapi/linux/genetlink.h |  1 +
>  net/netlink/genetlink.c        |  4 ++++
>  net/openvswitch/datapath.c     | 20 ++++++++++----------
>  3 files changed, 15 insertions(+), 10 deletions(-)
>
Looks good.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
