From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2.55] datapath: Add basic MPLS support to
 kernel
Date: Thu, 20 Mar 2014 13:25:45 +0900
Message-ID: <20140320042543.GA14980@verge.net.au>
References: <1394781160-8331-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1394781160-8331-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Mar 14, 2014 at 04:12:39PM +0900, Simon Horman wrote:
> Hi Pravin, Hi Jesse, Hi All,
> 
> I have updated this patch so that:
> 
> * The datapath rejects push MPLS actions in the presence of VLAN tags.
> 
>   I have done this by white-listing the following:
>   - ETH_P_IP (0x0800)
>   - ETH_P_ARP (0x0806)
>   - ETH_P_RARP (0x0835)
>   - ETH_P_IPV6 (0x86DD)

I realised this morning that at the very least the
MPLS ethertypes should be added to this list.

I plan to repost the patch accordingly.
But this change shouldn't affect any review of the rest
of the patch.

> 
>   Previously it was done by blacklisting the following:
>   - ETH_P_8021Q (0x8100)
>   - ETH_P_8021AD (0x88A8)
>   - ETH_P_QINQ1 (0x0x9100)
>   - ETH_P_QINQ2 (0x0x9200)
>   - ETH_P_QINQ3 (0x0x9300)
> 
>   Although the whitelist probably wants to be expanded
>   it seems to me to be a more conservative and safer
>   way to guard against unknown tag ordering.
> 
> to aid review this patch is available in git at:
> https://github.com/horms/openvswitch devel/mpls-v2.55
> 
> Simon Horman (1):
>   datapath: Add basic MPLS support to kernel
> 
>  OPENFLOW-1.1+                                   |   4 -
>  datapath/Modules.mk                             |   1 +
>  datapath/actions.c                              | 119 +++++++++-
>  datapath/datapath.c                             |   4 +-
>  datapath/flow.c                                 |  29 +++
>  datapath/flow.h                                 |  17 +-
>  datapath/flow_netlink.c                         | 297 ++++++++++++++++++++++--
>  datapath/flow_netlink.h                         |   2 +-
>  datapath/linux/compat/gso.c                     |  70 +++++-
>  datapath/linux/compat/gso.h                     |  41 +++-
>  datapath/linux/compat/include/linux/netdevice.h |   6 +-
>  datapath/linux/compat/netdevice.c               |  10 +-
>  datapath/mpls.h                                 |  15 ++
>  include/linux/openvswitch.h                     |   7 +-
>  14 files changed, 567 insertions(+), 55 deletions(-)
>  create mode 100644 datapath/mpls.h
> 
> -- 
> 1.8.5.2
> 
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
> 
