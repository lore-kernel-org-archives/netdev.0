From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V6 0/3] handle polling errors in vhost/vhost_net
Date: Thu, 24 Jan 2013 12:38:07 +0200
Message-ID: <20130124103807.GB9368@redhat.com>
References: <1358351078-58915-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980Ab3AXKd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 05:33:58 -0500
Content-Disposition: inline
In-Reply-To: <1358351078-58915-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2013 at 11:44:35PM +0800, Jason Wang wrote:
> This is an update version of last version to fix the handling of polling errors
> in vhost/vhost_net.
> 
> Currently, vhost and vhost_net ignore polling errors which can lead kernel
> crashing when it tries to remove itself from waitqueue after the polling
> failure. Fix this by:
> 
> - examing the POLLERR when setting backend and report erros to userspace
> - let tun always add to waitqueue in .poll() after the queue is created even if
>   it was detached.
> 
> Changes from V5:
> - use rcu_dereference() instead of the wrong rtnl_dereference() in data path
> - test with CONFIG_PROVE_RCU
> 
> Changes from V4:
> - check the detached state by tfile->detached and protect it by RCU
> 
> Changes from V3:
> - make a smaller patch that doesn't touch the whole polling state and only check
>   the polliner errors in backend setting.
> - add a patch that allows tuntap to do polling/reading/writing when detached
>   which could simplify the work of its user.
> 
> Changes from v2:
> - check poll->wqh instead of the wrong assumption about POLLERR and waitqueue
> - drop the whole tx polling state check since it was replaced by the wqh
>   checking
> - drop the buggy tuntap patch
> 
> Changes from v1:
> - restore the state before the ioctl when vhost_init_used() fails
> - log the error when meet polling errors in the data path
> - don't put into waitqueue when tun_chr_poll() return POLLERR
> 
> Jason Wang (3):
>   vhost_net: correct error handling in vhost_net_set_backend()
>   vhost_net: handle polling errors when setting backend
>   tuntap: allow polling/writing/reading when detached
> 
>  drivers/net/tun.c     |   45 ++++++++++++++++++++++++++-------------------
>  drivers/vhost/net.c   |   41 ++++++++++++++++++++++++++++-------------
>  drivers/vhost/vhost.c |   18 +++++++++++++++---
>  drivers/vhost/vhost.h |    2 +-
>  4 files changed, 70 insertions(+), 36 deletions(-)

Acked-by: Michael S. Tsirkin <mst@redhat.com>
