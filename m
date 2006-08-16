From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH 1/9] network namespaces: core and device list
Date: Wed, 16 Aug 2006 07:46:43 -0700
Message-ID: <1155739603.8377.7.camel@localhost.localdomain>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	 <20060815184836.A2882@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com, serue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:39127 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751188AbWHPOrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 10:47:05 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7GEl3WS019933
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 10:47:03 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7GEkoIZ148346
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 08:46:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7GEkn52001713
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 08:46:50 -0600
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060815184836.A2882@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 18:48 +0400, Andrey Savochkin wrote:
> 
>         /* Can survive without statistics */
>         stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
>         if (stats) {
>                 memset(stats, 0, sizeof(struct net_device_stats));
> -               loopback_dev.priv = stats;
> -               loopback_dev.get_stats = &get_stats;
> +               dev->priv = stats;
> +               dev->get_stats = &get_stats;
>         } 

With this much surgery it might be best to start using things that have
come along since this code was touched last, like kzalloc().

-- Dave

