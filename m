From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 1/2] tuntap: forbid calling TUNSETIFF when detached
Date: Fri, 11 Jan 2013 15:42:36 +0100
Message-ID: <20130111144236.GC2310@stefanha-thinkpad.muc.redhat.com>
References: <1357894242-25020-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357894242-25020-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 11, 2013 at 04:50:41PM +0800, Jason Wang wrote:
> @@ -1546,6 +1544,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  	struct net_device *dev;
>  	int err;
>  
> +	if (rcu_dereference_protected(tfile->detached, lockdep_rtnl_is_held()))
> +		return -EINVAL;
> +

How come none of the other tfile->detached users call rcu_*()?

Stefan
