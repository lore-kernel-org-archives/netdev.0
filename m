From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Don't limit the number of tunnels with generic name explicitly.
Date: Tue, 26 Feb 2008 10:47:44 +0300
Message-ID: <47C3C420.1060407@openvz.org>
References: <47BD6BD7.1060200@openvz.org>	<47BD6CE9.7000908@trash.net>	<47BD70B8.3030507@openvz.org> <20080223.202021.191612366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34258 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbYBZHru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 02:47:50 -0500
In-Reply-To: <20080223.202021.191612366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Thu, 21 Feb 2008 15:38:16 +0300
> 
>> Changelog:
>>
>> Use the added dev_alloc_name() call to create tunnel device name,
>> rather than iterate in a hand-made loop with an artificial limit.
>>
>> Thanks Patrick for noticing this.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Applied, but I had to rework this in two places that didn't
> apply cleanly.

That's because you skipped the first patch titled "Don't create 
tunnels with '%' in name.", which adds the dev_alloc_name() call 
and tosses the error paths a bit. Without this first patch, these 
four drivers become broken :( When user doesn't specify the name, 
the device's name will be e.g. "tunl%d", but not "tunl0" like 
he expects.

> The ip_gre.c and ipip.c changes remove a "failed" label but
> that can't be done in the current tree as there are other
> existing references.
> 

Yup :( this code was removed in that first patch...
