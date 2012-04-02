From: David Miller <davem@davemloft.net>
Subject: Re: [BUGFIX][PATCH 3/3] memcg/tcp: ignore tcp usage before
 accounting started
Date: Sun, 01 Apr 2012 23:41:13 -0400 (EDT)
Message-ID: <20120401.234113.1505269982606203786.davem@davemloft.net>
References: <4F7408B7.9090706@jp.fujitsu.com>
	<4F740AEF.7090900@jp.fujitsu.com>
	<4F742983.1080402@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: glommer@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783Ab2DBDlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:41:23 -0400
In-Reply-To: <4F742983.1080402@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glauber Costa <glommer@parallels.com>
Date: Thu, 29 Mar 2012 11:21:07 +0200

> On 03/29/2012 09:10 AM, KAMEZAWA Hiroyuki wrote:
>> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
>> starts before setting res->limit, there are already used resource.
>> After setting res->limit, the resource (already used) will be uncharged and
>> make res_counter below 0 because they are not charged. This causes warning.
>> 
>> This patch fixes that by adding res_counter_uncharge_nowarn().
>> (*) We cannot avoid this while we have 'account start' switch.
>> 
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> 
> Fine by me.
> 
> Acked-by: Glauber Costa <glommer@parallels.com>

I'm not applying patches that simply ignore accounting counter
underflows.

You must either:

1) Integrate the socket's existing usage when the limit is set.

2) Avoid accounting completely for a socket that started before
   the limit was set.

No half-way solutions, please.  Otherwise it is impossible to design
validations of the resource usage for a particular socket or group of
sockets, because they can always be potentially "wrong" and over the
limit.  That's a design for a buggy system.
