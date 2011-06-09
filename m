From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for iSCSI
 connections
Date: Thu, 9 Jun 2011 08:27:22 -0700
Message-ID: <20110609082722.492b46b5@nehalam.ftrdhcpuser.net>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
	<1307597376-5379-2-git-send-email-mchan@broadcom.com>
	<1307597376-5379-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eddie Wai" <eddie.wai@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57052 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab1FIP1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 11:27:32 -0400
In-Reply-To: <1307597376-5379-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Jun 2011 22:29:34 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

>  static int cnic_cm_alloc_mem(struct cnic_dev *dev)
>  {
>  	struct cnic_local *cp = dev->cnic_priv;
> +	u32 port_id;
>  
>  	cp->csk_tbl = kzalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
>  			      GFP_KERNEL);
>  	if (!cp->csk_tbl)
>  		return -ENOMEM;
>  
> +	get_random_bytes(&port_id, sizeof(port_id));

I think random32() or it's alias net_random() would be sufficient
for your needs here.
