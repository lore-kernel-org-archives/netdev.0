From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Wed, 11 Mar 2015 16:28:50 -0400 (EDT)
Message-ID: <20150311.162850.1722797143871993349.davem@davemloft.net>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us, sfeldma@gmail.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbbCKU2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:28:54 -0400
In-Reply-To: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 06 Mar 2015 13:47:00 -0800

> This patch is meant to collapse local and main into one by converting
> tb_data from an array to a pointer.  Doing this allows us to point the
> local table into the main while maintaining the same variables in the
> table.
> 
> As such the tb_data was converted from an array to a pointer, and a new
> array called data is added in order to still provide an object for tb_data
> to point to.
> 
> In order to track the origin of the fib aliases a tb_id value was added in
> a hole that existed on 64b systems.  Using this we can also reverse the
> merge in the event that custom FIB rules are enabled.
> 
> With this patch I am seeing an improvement of 20ns to 30ns for routing
> lookups as long as custom rules are not enabled, with custom rules enabled
> we fall back to split tables and the original behavior.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

I've applied this, let's see what happens.
