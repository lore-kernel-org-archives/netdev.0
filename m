From: Balbir Singh <balbir@in.ibm.com>
Subject: Re: [Patch 8/9] generic netlink utility functions
Date: Sun, 26 Mar 2006 22:14:35 +0530
Message-ID: <20060326164434.GC13362@in.ibm.com>
References: <1142296834.5858.3.camel@elinux04.optonline.net> <1142297705.5858.28.camel@elinux04.optonline.net>
Reply-To: balbir@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751490AbWCZQrW@vger.kernel.org>
To: Shailabh Nagar <nagar@watson.ibm.com>
Content-Disposition: inline
In-Reply-To: <1142297705.5858.28.camel@elinux04.optonline.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2006 at 07:55:05PM -0500, Shailabh Nagar wrote:
> genetlink-utils.patch
> 
> Two utilities for simplifying usage of NETLINK_GENERIC
> interface.
> 
> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
> Signed-off-by: Shailabh Nagar <nagar@watson.ibm.com>
> 
>  include/net/genetlink.h |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+)
> 
> Index: linux-2.6.16-rc5/include/net/genetlink.h
> ===================================================================
> --- linux-2.6.16-rc5.orig/include/net/genetlink.h	2006-03-11 07:41:32.000000000 -0500
> +++ linux-2.6.16-rc5/include/net/genetlink.h	2006-03-11 07:41:41.000000000 -0500
> @@ -150,4 +150,24 @@ static inline int genlmsg_unicast(struct
>  	return nlmsg_unicast(genl_sock, skb, pid);
>  }
>  
> +/**
> + * gennlmsg_data - head of message payload
> + * @gnlh: genetlink messsage header
> + */
> +static inline void *genlmsg_data(const struct genlmsghdr *gnlh)
> +{
> +       return ((unsigned char *) gnlh + GENL_HDRLEN);
> +}
> +
> +/**
> + * genlmsg_len - length of message payload
> + * @gnlh: genetlink message header
> + */
> +static inline int genlmsg_len(const struct genlmsghdr *gnlh)
> +{
> +       struct nlmsghdr *nlh = (struct nlmsghdr *)((unsigned char *)gnlh -
> +                                                   NLMSG_HDRLEN);
> +       return (nlh->nlmsg_len - GENL_HDRLEN - NLMSG_HDRLEN);
> +}
> +
>  #endif	/* __NET_GENERIC_NETLINK_H */
> 
>

Jamal,

Does the implementation of these utilities look ok? We use genlmsg_data()
in the delay accounting code but not genlmsg_len(), hence it might not
be very well tested (just reviewed).

Thanks,
Balbir 
