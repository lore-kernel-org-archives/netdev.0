From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: add a sock pointer to ip_queue_xmit() and
 friends
Date: Tue, 15 Apr 2014 13:06:04 -0700
Message-ID: <1397592364.4222.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397520840.4222.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHz2CGW_Eh5P_Z4=a-tfnp-S_62bZRXk2pLxes7ufEdfr0hwAQ@mail.gmail.com>
	 <1397572392.4222.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140415.131636.1847117096992048895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, netdev@vger.kernel.org,
	lucien.xin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:52921 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaDOUGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 16:06:06 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so9884511pbc.6
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 13:06:05 -0700 (PDT)
In-Reply-To: <20140415.131636.1847117096992048895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-15 at 13:16 -0400, David Miller wrote:

> This doesn't compile, I'd expect to see hunks such as:
> 
> @@ -184,7 +184,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
>  	dst->xfrm = NULL;
>  #endif
>  	dst->input = dst_discard;
> -	dst->output = dst_discard;
> +	dst->output = dst_discard_sk;
>  	dst->error = 0;
>  	dst->obsolete = initial_obsolete;
>  	dst->header_len = 0;
> 
> for this file, but I don't.  Maybe you posted an outdated revision of your
> patch?  There also aren't the necessary decnet and XFRM changes, layers
> which also use dst->output().
> 
> Anyways, I'm splitting up your patches and sorting this out.

Hmmpff. The truth is I did a "make allyesconfig;make -j24", and the
build completed, but I missed warnings.

And the thing even booted and ran properly.

Sorry for this, and thanks for taking care of the mess.
