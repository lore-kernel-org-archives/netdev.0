From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: sctp: bug-fixing: retran_path not set properly
 after transports recovering (v3)
Date: Thu, 14 Nov 2013 08:55:43 -0500
Message-ID: <20131114135543.GA14807@hmsreliant.think-freely.org>
References: <1384387106-8105-1-git-send-email-changxiangzhong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Chang Xiangzhong <changxiangzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47532 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab3KNNz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 08:55:57 -0500
Content-Disposition: inline
In-Reply-To: <1384387106-8105-1-git-send-email-changxiangzhong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 12:58:26AM +0100, Chang Xiangzhong wrote:
> When a transport recovers due to the new coming sack, SCTP should
> iterate all of its transport_list to locate the __two__ most recently used
> transport and set to active_path and retran_path respectively. The exising
> code does not find the two properly - In case of the following list:
> 
> [most-recent] -> [2nd-most-recent] -> ...
> 
> Both active_path and retran_path would be set to the 1st element.
> 
> The bug happens when:
> 1) multi-homing
> 2) failure/partial_failure transport recovers
> Both active_path and retran_path would be set to the same most-recent one, in
> other words, retran_path would not take its role - an end user might not even
> notice this issue.
> 
> Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
