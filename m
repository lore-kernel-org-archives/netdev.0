From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 08:24:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
 <87oalu1p16.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ying Xue <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cwang@twopensource.com" <cwang@twopensource.com>,
	"xemul@openvz.org" <xemul@openvz.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"maxk@qti.qualcomm.com" <maxk@qti.qualcomm.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"jchapman@katalix.com" <jchapman@katalix.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "'Eric W. Biederman'" <ebiederm@xmission.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.195]:58046 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbbELIZx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 04:25:53 -0400
In-Reply-To: <87oalu1p16.fsf_-_@x220.int.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman
> Sent: 09 May 2015 03:08
>
> This is long overdue, and is part of cleaning up how we allocate kernel
> sockets that don't reference count struct net.
...
> diff --git a/net/socket.c b/net/socket.c
> index b5f1f43ed8f4..9963a0b53a64 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1210,9 +1210,9 @@ int sock_create(int family, int type, int protocol, struct socket **res)
>  }
>  EXPORT_SYMBOL(sock_create);
> 
> -int sock_create_kern(int family, int type, int protocol, struct socket **res)
> +int sock_create_kern(struct net *net, int family, int type, int protocol, struct socket **res)
>  {
> -	return __sock_create(&init_net, family, type, protocol, res, 1);
> +	return __sock_create(net, family, type, protocol, res, 1);
>  }
>  EXPORT_SYMBOL(sock_create_kern);

Wouldn't it involve far less churn to add a new function that uses a non-default
namespace?

Changing the function prototype will a PITA for anyone doing back-ports of fixes.
(And more so for anyone trying to get a driver to build against kernels
that might have this change back-ported.)

	David
