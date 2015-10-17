From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/17] i40e: Lock for VSI's MAC filter list
Date: Sat, 17 Oct 2015 06:01:53 -0700 (PDT)
Message-ID: <20151017.060153.830867376192459210.davem@davemloft.net>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1445059711-45992-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kiran.patil@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbbJQMpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 08:45:46 -0400
In-Reply-To: <1445059711-45992-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 16 Oct 2015 22:28:15 -0700

>  
> +	WARN(!spin_is_locked(&vsi->mac_filter_list_lock),
> +	     "Missing mac_filter_list_lock\n");
> +

spin_is_locked() is, generally speaking, completely inappropriate to
use in assertions.

Because, on uniprocessor builds, it always evalutes to zero.
