From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH] xfrm: Notify changes in UDP encapsulation via netlink
Date: Tue, 28 Oct 2008 21:44:20 +0100
Message-ID: <1225226660.6976.18.camel@martin>
References: <20081028085119.6A30EEF9BA@strongswan.org>
	 <20081028.114828.158507859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:59959 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753053AbYJ1VKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:10:03 -0400
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id 984AD2F19EFA
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:44:23 +0100 (CET)
In-Reply-To: <20081028.114828.158507859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't see the code which will actually invoke the new
> ->new_mapping() method (either here or in a follow-on patch), so it's
> impossible to review these changes.

The patch is complete, sorry for being unclear.

xfrm_send_mapping is an implementation of a xfrm_mgr operation. 

>  static struct xfrm_mgr netlink_mgr = {
>         .id             = "netlink",
>         .notify         = xfrm_send_state_notify,
>         .notify_policy  = xfrm_send_policy_notify,
>         .report         = xfrm_send_report,
>         .migrate        = xfrm_send_migrate,
> +       .new_mapping    = xfrm_send_mapping,
> };

This operation is invoked from net/ipv4/esp4.c through the
km_new_mapping() function, km_new_mapping() invokes all registered key
managers. It is already implemented in the PF_KEY interface (pfkeyv2_mgr
in af_key.c), but is missing in the netlink xfrm interface. The patch
adds this functionality to the netlink interface.


