From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC 0/8] multiqueue API support for macvtap
Date: Thu, 23 May 2013 14:53:27 +0300
Message-ID: <20130523115327.GE17993@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 11:12:25AM +0800, Jason Wang wrote:
> Hi all:
> 
> This series implements a fully tuntap compatiable API which could be used by
> userspace to manage multi macvtap queues. The main parts is to add TUNSETQUEUE
> ioctl support for macvtap.
> 
> Patch 1 - 4 was some tuntap compatibility and misc cleanups.
> Patch 5 removes the linear search in macvtap by reshuffling the macvtaps array
> each time a queue is removed. After this, we could store both enabled and
> disabled queues in the same array without introducing extra data structure.
> Patch 6 let TUNSETIFF can create multiqueue device, nothing but some check were
> added.
> Patch 7 implement TUNSETQUEUE ioctl
> Patch 8 reports IFF_MULTI_QUEUE to userspace to notify the userspace that the
> multiqueue API is completed.
> 
> Flow caches implememtation were missed in this version, since I am doing rework
> on the tuntap flow caches. Have some some stress test with both netperf and
> pktgen.
> 
> Please review, thanks.

Overall looks good. Sent some comments on specific patches.

Thanks!

> Jason Wang (8):
>   macvlan: switch to use IS_ENABLED()
>   macvtap: return -EBADFD when TUNGETIFF fails
>   macvtap: introduce macvtap_get_vlan()
>   macvlan: reduce the max number of taps to 8
>   macvtap: eliminate linear search
>   macvtap: allow TUNSETIFF to create multiqueue device
>   macvtap: add TUNSETQUEUE ioctl
>   macvtap: enable multiqueue flag
> 
>  drivers/net/macvtap.c      |  265 ++++++++++++++++++++++++++++++-------------
>  include/linux/if_macvlan.h |   11 ++-
>  2 files changed, 194 insertions(+), 82 deletions(-)
