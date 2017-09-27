From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Thu, 28 Sep 2017 01:13:21 +0300
Message-ID: <20170927230042-mutt-send-email-mst@kernel.org>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 04:23:54PM +0800, Jason Wang wrote:
> Hi all:
> 
> We use flow caches based flow steering policy now. This is good for
> connection-oriented communication such as TCP but not for the others
> e.g connectionless unidirectional workload which cares only about
> pps. This calls the ability of supporting changing steering policies
> in tuntap which was done by this series.
> 
> Flow steering policy was abstracted into tun_steering_ops in the first
> patch. Then new ioctls to set or query current policy were introduced,
> and the last patch introduces a very simple policy that select txq
> based on processor id as an example.
> 
> Test was done by using xdp_redirect to redirect traffic generated from
> MoonGen that was running on a remote machine. And I see 37%
> improvement for processor id policy compared to automatic flow
> steering policy.

For sure, if you don't need to figure out the flow hash then you can
save a bunch of cycles.  But I don't think the cpu policy is too
practical outside of a benchmark.

Did you generate packets and just send them to tun? If so, this is not a
typical configuration, is it? With packets coming e.g.  from a real nic
they might already have the hash pre-calculated, and you won't
see the benefit.

> In the future, both simple and sophisticated policy like RSS or other guest
> driven steering policies could be done on top.

IMHO there should be a more practical example before adding all this
indirection. And it would be nice to understand why this queue selection
needs to be tun specific.

> Thanks
> 
> Jason Wang (3):
>   tun: abstract flow steering logic
>   tun: introduce ioctls to set and get steering policies
>   tun: introduce cpu id based steering policy
> 
>  drivers/net/tun.c           | 151 +++++++++++++++++++++++++++++++++++++-------
>  include/uapi/linux/if_tun.h |   8 +++
>  2 files changed, 136 insertions(+), 23 deletions(-)
> 
> -- 
> 2.7.4
