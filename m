From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Thu, 22 Jun 2017 15:38:00 -0700
Message-ID: <20170622153800.67f9635f@cakuba.netronome.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
        <1498050286-17141-4-git-send-email-galp@mellanox.com>
        <20170621213353.318e5d37@cakuba.netronome.com>
        <311af079-cf95-b487-f59a-9566e17296bf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gal Pressman <galp@mellanox.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:36584 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753875AbdFVWiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 18:38:09 -0400
In-Reply-To: <311af079-cf95-b487-f59a-9566e17296bf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jun 2017 11:33:39 +0300, Gal Pressman wrote:
> > Is my reading correct that in case the reason is not in the
> > pddr2ethtool_table opaque binary data will be passed from the firmware
> > to user space?  Is there any particular reason to allow for this?  If
> > it's just for the rare scenario where a new error code needs to be
> > added perhaps it would be enough to dump the FW-provided message to the
> > logs?  
> 
> No binary data is passed in this patch, the monitor_opcode is simply a vendor specific
> 16 bit id that is used when the reason  is not generic enough to have it's own enum.

Sorry if I'm wrong, I thought this would potentially copy
ETH_GSTRING_LEN bytes to userspace:

+	if (status_message)
+		memcpy(status_message,
+		       MLX5_ADDR_OF(pddr_reg, out, page_data.troubleshooting_info_page.status_message),
+		       ETH_GSTRING_LEN);

I'm also still not sure why a reason would not be generic enough for
the enum, if it fits in the 16bit vendor enum... 
