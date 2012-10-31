From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 3/8] bridge: implement BPDU blocking
Date: Wed, 31 Oct 2012 02:38:46 +0000 (UTC)
Message-ID: <k6q2vm$1ug$1@ger.gmane.org>
References: <20121030005731.843020405@vyatta.com>
 <20121030005835.462418417@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:42799 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932324Ab2JaCjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 22:39:03 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TTOCx-0007vc-NR
	for netdev@vger.kernel.org; Wed, 31 Oct 2012 03:39:07 +0100
Received: from 112.132.138.96 ([112.132.138.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 03:39:07 +0100
Received: from xiyou.wangcong by 112.132.138.96 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 03:39:07 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Oct 2012 at 00:57 GMT, Stephen Hemminger <shemminger@vyatta.com> wrote:
> --- a/net/bridge/br_stp_bpdu.c	2012-10-29 17:07:08.005982838 -0700
> +++ b/net/bridge/br_stp_bpdu.c	2012-10-29 17:31:14.327457434 -0700
> @@ -170,6 +170,13 @@ void br_stp_rcv(const struct stp_proto *
>  	if (!ether_addr_equal(dest, br->group_addr))
>  		goto out;
>  
> +	if (p->flags & BR_BPDU_GUARD) {
> +		br_notice(br, "BPDU received on blocked port %u(%s)\n",
> +			  (unsigned int) p->port_no, p->dev->name);

net_ratelimit() ?
