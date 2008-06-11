From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Fix memory leak when deleting addresses
Date: Thu, 12 Jun 2008 02:42:03 +0900 (JST)
Message-ID: <20080612.024203.04460597.yoshfuji@linux-ipv6.org>
References: <20080604234934.GI20815@postel.suug.ch>
	<20080605.112646.51075203.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59278 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbYFKRlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:41:20 -0400
In-Reply-To: <20080605.112646.51075203.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080605.112646.51075203.yoshfuji@linux-ipv6.org> (at Thu, 05 Jun 2008 11:26:46 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20080604234934.GI20815@postel.suug.ch> (at Thu, 5 Jun 2008 01:49:34 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > ip6_del_rt() may fail in which case the dst/route is not released.
> 
> If prefix is ::/64 and ...
> 
> The only case ip6_del_rt() does not call dst_release() is when rt is
> ip6_null_entry.  In that case we should skip whole the logic in the
> caller, anyway.

Well, actually, I've found that this cannot even happen
because rt6_lookup() return NULL whenever it hits
ipv6_null_entry.

So, I'm going to drop this.

--yoshfuji
