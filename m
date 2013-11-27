From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Do not double-count received packets
Date: Wed, 27 Nov 2013 10:12:45 +0800
Message-ID: <5295551D.6070509@redhat.com>
References: <1385487432-17651-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099Ab3K0CMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 21:12:50 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAR2Cojn006876
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 21:12:50 -0500
In-Reply-To: <1385487432-17651-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2013 01:37 AM, Vlad Yasevich wrote:
> Currently macvlan will count received packets after calling each
> vlans receive handler.   Macvtap attempts to count the packet
> yet again when the user reads the packet from the tap socket.
> This code doesn't do this consistently either.  Remove the
> counting from macvap and let only macvlan count received
> packets.
>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 10 ----------
>  1 file changed, 10 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index dc76670..50f8dce 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -767,7 +767,6 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  				const struct sk_buff *skb,
>  				const struct iovec *iv, int len)
>  {
> -	struct macvlan_dev *vlan;
>  	int ret;
>  	int vnet_hdr_len = 0;
>  	int vlan_offset = 0;
> @@ -821,15 +820,6 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  	copied += len;
>  
>  done:
> -	rcu_read_lock();
> -	vlan = rcu_dereference(q->vlan);
> -	if (vlan) {
> -		preempt_disable();
> -		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
> -		preempt_enable();
> -	}
> -	rcu_read_unlock();
> -
>  	return ret ? ret : copied;
>  }
>  

Acked-by: Jason Wang <jasowang@redhat.com>
