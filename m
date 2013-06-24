From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] vxlan: introduce vxlan_rdst_append
Date: Mon, 24 Jun 2013 06:02:37 +0000 (UTC)
Message-ID: <kq8nds$ao1$1@ger.gmane.org>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1372004543-24675-2-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56933 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115Ab3FXGD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 02:03:27 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UqzrZ-0006ip-TD
	for netdev@vger.kernel.org; Mon, 24 Jun 2013 08:03:23 +0200
Received: from 60.160.82.190 ([60.160.82.190])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:02:53 +0200
Received: from xiyou.wangcong by 60.160.82.190 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:02:53 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> to allow remotes list management for both FDB entries and default
> destinations
>
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
>  drivers/net/vxlan.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 212a256..e5fb6568 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -386,14 +386,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
>  	return f;
>  }
>  
> -/* Add/update destinations for multicast */
> -static int vxlan_fdb_append(struct vxlan_fdb *f,
> +static int vxlan_rdst_append(struct list_head *remotes,
>  			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)


I think you need to align the above line.


>  {
>  	struct vxlan_rdst *rd;
>  
>  	/* protected by vxlan->hash_lock */
> -	list_for_each_entry(rd, &f->remotes, list) {
> +	list_for_each_entry(rd, remotes, list) {

This patch is based on Stephen's patches which are not yet merged into
net-next, right? If so, I think you have to wait. My IPv6 patches are
pending because of his patches too.


>  		if (rd->remote_ip == ip &&
>  		    rd->remote_port == port &&
>  		    rd->remote_vni == vni &&
> @@ -409,11 +408,18 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
>  	rd->remote_vni = vni;
>  	rd->remote_ifindex = ifindex;
>  
> -	list_add_tail_rcu(&rd->list, &f->remotes);
> +	list_add_tail_rcu(&rd->list, remotes);
>  
>  	return 1;
>  }
>  
> +/* Add/update destinations for multicast */
> +static int vxlan_fdb_append(struct vxlan_fdb *f,
> +			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)

You need to align this line too.
