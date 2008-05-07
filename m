From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read lock.
Date: Wed, 07 May 2008 09:54:53 +0400
Message-ID: <4821442D.8010801@openvz.org>
References: <48206F4C.5050105@openvz.org>	<200805061840.37713.netdev@axxeo.de>	<4820997E.1070305@openvz.org> <20080506.134047.86330538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43136 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761317AbYEGF62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 01:58:28 -0400
In-Reply-To: <20080506.134047.86330538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Tue, 06 May 2008 21:46:38 +0400
> 
>> I do not quite like doing so. Since this relies on fact that kfree bears
>> NULL pointers. But if we ever switch from kmalloc to kmem_cache_alloc,
>> this will result in an oops.
> 
> The whole reason we made kfree allow NULL points is so that
> checks for it would be ommitted at kfree calls sides, whether
> they be direct or indirect.

Hm... I really thought that this check in kfree is just for sanity 
against some 3rd part code. But why kmem_cache_free() is not such then?

> Adding the check for some theoretical-or-not future change is
> rediculious.

Well, this makes sense. Shall I resubmit the set?

Thanks,
Pavel
