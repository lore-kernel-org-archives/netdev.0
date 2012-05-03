From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: take care of cloned skbs in
 tcp_try_coalesce()
Date: Thu, 03 May 2012 05:14:29 +0200
Message-ID: <1336014869.22133.821.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>
	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>
	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>
	 <1335977179.22133.599.camel@edumazet-glaptop> <4FA17781.6080306@intel.com>
	 <1335982515.22133.610.camel@edumazet-glaptop> <4FA19F5B.7040407@intel.com>
	 <1336009974.22133.706.camel@edumazet-glaptop>  <4FA1F4C3.8000804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
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
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33602 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2ECDOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 23:14:34 -0400
Received: by wibhj6 with SMTP id hj6so5355723wib.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 20:14:33 -0700 (PDT)
In-Reply-To: <4FA1F4C3.8000804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 20:00 -0700, Alexander Duyck wrote:

> This is exactly my point.  The way your current code works the check in 
> pskb_expand_head will not detect the header is cloned.
> 
> So for example lets say you have one of your skbs that goes through and 
> is merged.
> 
> 1.  You start with a cloned skb.  dataref = 2, head_frag page count = 1;
> 2.  You go through tcp_try_coalesce.  dataref = 2, head_frag page count = 2;
> 3.  You call __kfree_skb on the skb.  dataref = 1, head_frag page count = 2;


If page count was incremented in 2., this is because we stole the head.

But we could not stole the head since dataref = 2

So try to find a real example, based on current state, not on the first
patch I sent, since we made progress since this time.

Thanks
