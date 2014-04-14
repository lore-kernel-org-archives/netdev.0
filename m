From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net IPv6: Remove unnecessary argument of
 ndisc_send_ns and ndisc_send_na
Date: Mon, 14 Apr 2014 13:22:01 -0400 (EDT)
Message-ID: <20140414.132201.372297856628816549.davem@davemloft.net>
References: <534B5EAB.9050803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbaDNRWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:22:03 -0400
In-Reply-To: <534B5EAB.9050803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Mon, 14 Apr 2014 09:36:03 +0530

> The 'neigh' argument of 'ndisc_send_ns' and 'ndisc_send_na' are not used in
> these functions. So this argument could be removed.
> 
> And a minor change of 'optlen' assignment in those functions. the compound
> addition and assignment operator is not needed as 'optlen' value is always
> zero.
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> ---
> I am not sure whether 'neigh' argument is intentional or planned for any
> future use. If you find this is unnecessary, this patch could be considered.
> 
> And ndisc_send_na is used as a function pointer in ipv6_stub. This may affect
> anybody using this structure. But with default configuration built, I didn't
> get any error or warning. Kindly consider this scenario also.
> 
> Please ignore the previous patch as it doesn't have optlen modification in
> ndisc_send_na

I really don't like this change, and furthermore this breaks the build
as Hideaki YOSHIFUJI pointed out.  Drivers use the ipv6_stub methods and
you thus have to update all of the ones that use the ->ndisc_*().
