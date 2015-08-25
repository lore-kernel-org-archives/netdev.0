From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/2] Optimize the snmp stat aggregation for large
 cpus
Date: Tue, 25 Aug 2015 16:07:30 -0700 (PDT)
Message-ID: <20150825.160730.1747721171751442778.davem@davemloft.net>
References: <y>
	<1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, edumazet@google.com,
	hannes@stressinduktion.org, tom@herbertland.com, azhou@nicira.com,
	ebiederm@xmission.com, ipm@chirality.org.uk,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: raghavendra.kt@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbHYXHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:07:31 -0400
In-Reply-To: <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Tue, 25 Aug 2015 13:24:24 +0530

> Please let me know if you have suggestions/comments.

Like Eric Dumazet said the idea is good but needs some adjustments.

You might want to see whether a per-cpu work buffer works for this.

It's extremely unfortunately that we can't depend upon the destination
buffer being properly aligned, because we wouldn't need a temporary
scratch area if it were aligned properly.
