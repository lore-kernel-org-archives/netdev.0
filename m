From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Thu, 16 Jan 2014 17:32:30 -0800
Message-ID: <1389922350.31367.447.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140116.171303.2113967209121208034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maze@google.com,
	cwang@twopensource.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f169.google.com ([209.85.161.169]:62774 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaAQBce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:32:34 -0500
Received: by mail-gg0-f169.google.com with SMTP id j5so1121745ggn.14
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 17:32:33 -0800 (PST)
In-Reply-To: <20140116.171303.2113967209121208034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 17:13 -0800, David Miller wrote:

> Why do we have to handle DST_NOCACHE specially?  We hold a reference
> and dst_release() knows what to do with DST_NOCACHE routes.
> 
> Or is it semantically undesirable for tunnels to cache these routes?
> If so, why do we leave sockets caching DST_NOCACHE routes just fine?

If DST_NOCACHE is set on a dst, this dst cannot be used by rcu users,
because dst_release() will immediately free the dst, without rcu grace
period.
