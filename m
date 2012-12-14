From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: fix ambigious multiqueue API
Date: Fri, 14 Dec 2012 13:16:02 -0500 (EST)
Message-ID: <20121214.131602.930994526954658624.davem@davemloft.net>
References: <1355478810-10144-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pmoore@redhat.com,
	mprivozn@redhat.com, wkevils@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355478810-10144-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 14 Dec 2012 17:53:30 +0800

> The current multiqueue API is ambigious which may confuse both user and LSM to
> do things correctly:
> 
> - Both TUNSETIFF and TUNSETQUEUE could be used to create the queues of a tuntap
>   device.
> - TUNSETQUEUE were used to disable and enable a specific queue of the
>   device. But since the state of tuntap were completely removed from the queue,
>   it could be used to attach to another device (there's no such kind of
>   requirement currently, and it needs new kind of LSM policy.
> - TUNSETQUEUE could be used to attach to a persistent device without any
>   queues. This kind of attching bypass the necessary checking during TUNSETIFF
>   and may lead unexpected result.
> 
> So this patch tries to make a cleaner and simpler API by:
> 
> - Only allow TUNSETIFF to create queues.
> - TUNSETQUEUE could be only used to disable and enabled the queues of a device,
>   and the state of the tuntap device were not detachd from the queues when it
>   was disabled, so TUNSETQUEUE could be only used after TUNSETIFF and with the
>    same device.
> 
> This is done by introducing a list which keeps track of all queues which were
> disabled. The queue would be moved between this list and tfiles[] array when it
> was enabled/disabled. A pointer of the tun_struct were also introdued to track
> the device it belongs to when it was disabled.
> 
> After the change, the isolation between management and application could be done
> through: TUNSETIFF were only called by management software and TUNSETQUEUE were
> only called by application.For LSM/SELinux, the things left is to do proper
> check during tun_set_queue() if needed.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
