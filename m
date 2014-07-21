From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] net: print net_device name/state more
 often
Date: Sun, 20 Jul 2014 20:39:42 -0700 (PDT)
Message-ID: <20140720.203942.1635861091234493900.davem@davemloft.net>
References: <1405619171-18172-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbaron@akamai.com, edumazet@google.com,
	vyasevic@redhat.com, stephen@networkplumber.org, hkchu@google.com,
	bhutchings@solarflare.com, joe@perches.com
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbaGUDjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:39:44 -0400
In-Reply-To: <1405619171-18172-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 17 Jul 2014 19:46:08 +0200

> Currently we use net_device->name only if it's the NETREG_REGISTERED
> reg_state, otherwise we return "(unregistered device)".
> 
> However, we always populate net_device->name on creation, so it's always
> available to us for use. The only caveat is that we might have a name like
> "eth%d", in which case we cannot use it as it might change in the future.
> 
> Also, the net_device might not be NETREG_UNREGISTERED when the function is
> called (_UNINITIALIZED, _UNREGISTERING, _RELEASED, _DUMMY), so it's
> misleading.
> 
> So, a better way would be to always return the dev->name in netdev_name(),
> unless it's in the form of "eth%d" or it's empty, then return
> "unnamed net_device". This way we'll always return the name in
> NETREG_REGISTERED reg_state, and also return it in other states, when
> possible.
> 
> Also, to be more verbose on non-NETREG_REGISTERED states, add a function
> netdev_reg_state(), which returns a string describing the state, and use it
> in netdev_printk()-related functions. If the dev is in NETREG_REGISTERED
> state then a void string is regurned and, thus, nothing changes.
> 
> After these two patches we'll have the same behaviour in the usual cases,
> and more verbose in non-standardad/buggy ones.
> 
> v2->v3:
> Correct the string for _UNINITIALIZED and warn on a bad reg_state,
> per Joe Perches's comments.
> 
> v1->v2:
> As Tom Gundersen suggested, there might be a case when we have an empty
> string as a name for a device, so account this also and return "unnamed
> device" for that case too.

Series applied, thanks.
