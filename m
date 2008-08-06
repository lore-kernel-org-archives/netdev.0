From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] net/ipv4/route.c: fix build error
Date: Wed, 06 Aug 2008 16:04:51 +0300
Message-ID: <4899A173.2050807@teltonika.lt>
References: <20080727213905.GA4499@elte.hu>	<20080727214250.GA5917@elte.hu>	<489269AB.8050706@cn.fujitsu.com> <20080731.205132.203087940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, mingo@elte.hu, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:44777 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459AbYHFNLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 09:11:35 -0400
In-Reply-To: <20080731.205132.203087940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 01 Aug 2008 09:40:59 +0800
> 
>> Dave, the build error keeps showing several days.
> 
> I've applied Ingo's patch, thanks.

And after merging this patch:
[PATCH] ipv4_static_sysctl_init() should be under CONFIG_SYSCTL
author	Al Viro <viro@zeniv.linux.org.uk>
	Wed, 30 Jul 2008 10:32:52 +0000 (06:32 -0400)
committer	Al Viro <viro@zeniv.linux.org.uk>
	Fri, 1 Aug 2008 15:25:22 +0000 (11:25 -0400)
commit	a1bc6eb4b499ae67ada9a01660010580b6569403

This function is over ifdef'ed :)

#ifdef CONFIG_SYSCTL
/*
  * We really need to sanitize the damn ipv4 init order, then all
  * this nonsense will go away.
  */
void __init ip_static_sysctl_init(void)
{
#ifdef CONFIG_SYSCTL
	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
#endif
}
#endif

BR,
Paulius Zaleckas
