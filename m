From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 09:25:12 +0100
Message-ID: <20110321082512.GB27581@secunet.com>
References: <4D86E603.8080704@cn.fujitsu.com>
 <20110320.225542.71119753.davem@davemloft.net>
 <4D86F1FD.3080009@cn.fujitsu.com>
 <20110320.234606.183056322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37707 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab1CUIZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 04:25:14 -0400
Content-Disposition: inline
In-Reply-To: <20110320.234606.183056322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 20, 2011 at 11:46:06PM -0700, David Miller wrote:
> 
> Ok, thanks for the explanation.
> 
> I think there is a simple way out of this:
> 
> 1) Rename current xfrm_init_state to __xfrm_init_state, add
>    "bool init_replay" argument.  Add the xfrm_init_replay()
>    call, as in your patch, but conditionalized on this boolean.
> 
> 2) Implement xfrm_init_state as inline, which calls
>    __xfrm_init_state(..., true)
> 
> 3) Replace xfrm_init_state() call in xfrm_user.c with
>    __xfrm_init_state(..., false)
> 
> This seems to avoid all the problems.  We don't need to touch every
> caller, and we avoid initializing the replay state twice in xfrm_user
> 

Btw, looking a bit closer to this. I think it would look a bit cleaner
if we would add the xfrm_init_replay() call to xfrm_init_state() and
to move the xfrm_init_state() call in xfrm_state_construct() behind
the assign of the replay settings.
