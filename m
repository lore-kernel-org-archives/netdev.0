From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 16:46:31 +0300
Message-ID: <48D8F337.2050103@iki.fi>
References: <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:37675 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbYIWNqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 09:46:36 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1737249fgg.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 06:46:34 -0700 (PDT)
In-Reply-To: <20080923133234.GA30370@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 04:30:06PM +0300, Timo Ter=E4s wrote:
>> I have no strong opinion either way. So what ever you want, I'm
>> happy to provide a patch for.
>=20
> Let's just leave it as it is for now.

Well, 1 is an improvement over the current implementation, so
I think it'd be better than not doing anything.

>>> What about xfrm_cfg_mutex?
>> It's used only in xfrm_state_gc_task. xfrm_state_walk_{init,done}
>> touch xfrm_state_walks list without locking properly. At least in
>> the version I'm looking (=3D net-next-2.6 via git web interface).
>=20
> Their callers should be holding it.

Ah, the other layers take it at least on _walk_init paths. But
_walk_done can be called from recv() syscalls. The af_key
implementation does not take xfrm_cfg_mutex there. I don't think
xfrm_user does that either as it does not pass cb_mutex to
netlink_kernel_create. So at least the _state_walk_done path
is unsafe as-is, I think.

- Timo
