From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next:master 194/196] include/net/sock.h:1367:9: error: implicit
 declaration of function 'lockdep_is_held'
Date: Fri, 08 Apr 2016 00:12:07 +0200
Message-ID: <1460067127.988018.572315241.7F1FE712@webmail.messagingengine.com>
References: <201604080541.jzrX1awl%fengguang.wu@intel.com>
 <20160407.170937.292677537698351913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:55154 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753186AbcDGWMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:12:14 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id D188D211ED
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 18:12:07 -0400 (EDT)
In-Reply-To: <20160407.170937.292677537698351913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Apr 7, 2016, at 23:09, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Fri, 8 Apr 2016 05:00:42 +0800
> 
> >    include/net/sock.h: In function 'lockdep_sock_is_held':
> >>> include/net/sock.h:1367:9: error: implicit declaration of function 'lockdep_is_held' [-Werror=implicit-function-declaration]
> >      return lockdep_is_held(&sk->sk_lock) ||
> ...
> >   1361	} while (0)
> >   1362	
> >   1363	static bool lockdep_sock_is_held(const struct sock *csk)
> >   1364	{
> >   1365		struct sock *sk = (struct sock *)csk;
> >   1366	
> >> 1367		return lockdep_is_held(&sk->sk_lock) ||
> >   1368		       lockdep_is_held(&sk->sk_lock.slock);
> >   1369	}
> 
> Hmmm, Hannes to we need to make this a macro just like lockdep_is_held()
> is?

I think my newest patch should fix it. I simply forgot the inline
keyword. inline functions get invisible if not used by the compiler.

Sorry,
Hannes
