From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] ipv6: fix multipath route replace error recovery
Date: Wed, 09 Sep 2015 14:10:59 -0700 (PDT)
Message-ID: <20150909.141059.1681588831579060449.davem@davemloft.net>
References: <1441734784-34416-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, mkubecek@suse.cz,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504AbbIIVLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:11:00 -0400
In-Reply-To: <1441734784-34416-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  8 Sep 2015 10:53:04 -0700

> This patch reduces the possibility of this by doing the following:
> a) Changes the existing multipath route add code to a two stage process:
>   build rt6_infos + insert them
> 	ip6_route_add rt6_info creation code is moved into
> 	ip6_route_info_create.
> b) This ensures that most errors are caught during building rt6_infos
>   and we fail early
> c) Separates multipath add and del code. Because add needs the special
>   two stage mode in a) and delete essentially does not care.
> d) In any event if the code fails during inserting a route again, a
>   warning is printed (This should be unlikely)

Looks good, follows the usual "prepare/commit" paradigm.

Applied, thanks.

For net-next, it might be nice to make ip6_route_info_create() return
error pointers instead of returning the rt pointer by reference.
