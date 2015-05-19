From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 19 May 2015 18:01:17 +0000
Message-ID: <1432058488417.98688@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	<1432045826.5304.6.camel@opteya.com>
	<555B4EBE.7010900@mellanox.com>,<CAGgvQNRjSVcOfQB3bhXTdPoa04Hs7jc1+hXvL99EqDjbaaOw=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Parav Pandit <parav.pandit-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGgvQNRjSVcOfQB3bhXTdPoa04Hs7jc1+hXvL99EqDjbaaOw=A@mail.gmail.com>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 19, 2015 7:39 PM, Parav Pandit <parav.pandit-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org> wrote:
> This has come up during our first round of patch set for RoCEv2.
> However due to last set of changes in this patch set, we decided to
> move in for later submission.
> 
> Current high design approach to support this is:
> 
> A callback function registered to IP stack for IP address
> assignment/removal. (it could be done possibly done for GID entry
> update, instead of IP)
> For each such namespace, for device supporting RoCEv2, one UDP socket
> with RoCEv2 UDP port would be created and destroyed.

This needs to be done to take ownership of the RoCEv2 UDP port of course, but there is more to RoCE namespace support then that. You will need to de-multiplex rdma_cm_id requests from a shared ib_cm_id similarly to what is done in the InfiniBand patch-set here. Using the new RoCE GID cache should make it relatively easy. In addition, in order to support link-layer address resolution in the verbs layer as it is done today, we may need to add namespace support to the modify QP verb and the create AH verb.

Haggai--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
