From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Wed, 02 May 2012 22:23:07 +0200
Message-ID: <1335990187.22133.636.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>
	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>
	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>
	 <1335977179.22133.599.camel@edumazet-glaptop>
	 <1335981358.22133.605.camel@edumazet-glaptop>
	 <1335988709.22133.632.camel@edumazet-glaptop>
	 <1335989484.9611.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44027 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab2EBUXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 16:23:14 -0400
Received: by bkcji2 with SMTP id ji2so805686bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 13:23:12 -0700 (PDT)
In-Reply-To: <1335989484.9611.11.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 13:11 -0700, Joe Perches wrote:

> It might be useful to comment that this is/can be initialized to
> false in tcp_try_coalesce via tcp_recv_queue.


> Otherwise this looks like a possibly uninitialized test
> of fragstolen.  Maybe there's a path where tail is null
> in tcp_recv_queue and it's an uninitialized test anyway.

If tcp_queue_rcv() returns 1, fragstolen is initialized in
tcp_try_coalesce().

If tcp_queue_rcv() returns 0, fragstolen content is undefined and we
dont care.

If a compiler or static checker complains, its only their problem.
