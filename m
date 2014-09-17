From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages for
 smaller port MTUs
Date: Wed, 17 Sep 2014 18:43:51 -0400
Message-ID: <20140917224351.GM26828@oracle.com>
References: <5419F3E5.4050708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18507 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521AbaIQWn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:43:57 -0400
Content-Disposition: inline
In-Reply-To: <5419F3E5.4050708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/17/14 16:49), David L Stevens wrote:
> +
> +			rt = ip_route_output_key(dev_net(dev), &fl4);
> +			if (!IS_ERR(rt)) {

As I've mentioned before, this layering violation makes me uneasy,
so its benefits should be evaluated carefully.  You will typically not be
able to find an rt for packets coming here from any application
that does not itself use/update the FIB, e.g., uspace based packet-injectors (PF_PACKET-based applications, intel dpdk-based uspace stacks etc.)

--Sowmini
