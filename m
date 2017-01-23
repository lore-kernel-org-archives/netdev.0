From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Mon, 23 Jan 2017 22:37:32 +0100
Message-ID: <20170123213732.GF20894@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <CAEA6p_DxVMAry1PCz_idmk=TGpnnTib3WpWso03FB1oMVXN+sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:63008 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdAWVhj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 16:37:39 -0500
Content-Disposition: inline
In-Reply-To: <CAEA6p_DxVMAry1PCz_idmk=TGpnnTib3WpWso03FB1oMVXN+sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 01:28:53PM -0800, Wei Wang wrote:
> Hi Willy,
> 
> True. If you call connect() multiple times on a socket which already has
> cookie without a write(), the second and onward connect() call will return
> EINPROGRESS.
> It is basically because the following code block in __inet_stream_connect()
> can't distinguish if it is the first time connect() is called or not:
> 
> case SS_CONNECTING:
>                 if (inet_sk(sk)->defer_connect)  <----- defer_connect will
> be 0 only after a write() is called
>                         err = -EINPROGRESS;
>                 else
>                         err = -EALREADY;
>                 /* Fall out of switch with err, set for this state */
>                 break;

Ah OK that totally makes sense, thanks for the explanation!

> I guess we can add some extra logic here to address this issue. So the
> second connect() and onwards will return EALREADY.

If that's possible at little cost it would be nice, because your patch
makes it so easy to enable TFO on outgoing connections now that I
expect many people will blindly run the setsockopt() before connect().

Do not hesitate to ask me to run some tests. While 4 years ago it was
not easy, here it's very simple for me. By the way I'm seeing an ~10%
performance increase on haproxy by enabling this, it's really cool!

Thanks,
Willy
