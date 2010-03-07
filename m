From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 2/3] Provides multiple submits and asynchronous
	notifications.
Date: Sun, 7 Mar 2010 13:18:16 +0200
Message-ID: <20100307111816.GC20004@redhat.com>
References: <1267868318-19268-1-git-send-email-xiaohui.xin@intel.com> <1267868318-19268-2-git-send-email-xiaohui.xin@intel.com> <1267868318-19268-3-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu,
	jdike@c2.user-mode-linux.org
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1267868318-19268-3-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/* The structure to notify the virtqueue for async socket */
> +struct vhost_notifier {
> +	struct list_head list;
> +	struct vhost_virtqueue *vq;
> +	int head;
> +	int size;
> +	int log;
> +	void *ctrl;
> +	void (*dtor)(struct vhost_notifier *);
> +};
> +

So IMO, this is not the best interface between vhost
and your driver, exposing them to each other unnecessarily.

If you think about it, your driver should not care about this structure.
It could get e.g. a kiocb (sendmsg already gets one), and call ki_dtor
on completion.  vhost could save it's state in ki_user_data.  If your
driver needs to add more data to do more tracking, I think it can put
skb pointer in the private pointer.

-- 
MST
