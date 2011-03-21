From: David Miller <davem@davemloft.net>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Sun, 20 Mar 2011 22:55:42 -0700 (PDT)
Message-ID: <20110320.225542.71119753.davem@davemloft.net>
References: <4D86E603.8080704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751039Ab1CUFzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 01:55:03 -0400
In-Reply-To: <4D86E603.8080704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 21 Mar 2011 13:45:39 +0800

> Commit 'xfrm: Move IPsec replay detection functions to a separate file'
>   (9fdc4883d92d20842c5acea77a4a21bb1574b495)
> introduce repl field to struct xfrm_state, and only initialize it
> under SA's netlink create path, the other path, such as pf_key, the
> repl field remaining uninitialize. So if the SA is created by pf_key,
> any input packet with SA's encryption algorithm will cause panic.

Please, either add an xfrm_init_replay() call to the appropriate spot
in net/key/af_key.c or, if possible, only have the one call in
xfrm_init_state().  Don't leave two calls, one in xfrm_user.c and one
in xfrm_state.c

Anyways, I don't think just making one call from xfrm_init_state() is
possible, because the replay settings need to be assigned before we
can properly call xfrm_init_replay().

Therefore, please fix this by adding the necessary call to af_key.c

Thanks.
