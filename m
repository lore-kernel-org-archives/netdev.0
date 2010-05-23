From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bug report: xfrm: potential null deref in xfrm_bundle_lookup()
Date: Sun, 23 May 2010 21:06:31 +0300
Message-ID: <4BF96EA7.9050101@iki.fi>
References: <20100522202430.GN22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63239 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab0EWSGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 14:06:38 -0400
Received: by wwe15 with SMTP id 15so25719wwe.19
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 11:06:36 -0700 (PDT)
In-Reply-To: <20100522202430.GN22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2010 11:24 PM, Dan Carpenter wrote:
> This is a smatch thing.  I couldn't tell if it was a real issue so I
> thought I would send this mail to the experts.  :)
> 
> net/xfrm/xfrm_policy.c +1679 xfrm_bundle_lookup(51)
> 	error: we previously assumed 'xdst' could be null.
>   1672          new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family, dst_orig);
>   1673          if (IS_ERR(new_xdst)) {
>   1674                  err = PTR_ERR(new_xdst);
>   1675                  if (err != -EAGAIN)
>   1676                          goto error;
>   1677                  if (oldflo == NULL)
>   1678                          goto make_dummy_bundle;
>   1679                  dst_hold(&xdst->u.dst);
>                                   ^^^^^^^^^^^
> 	Can xdst be NULL here?  It would have to be something like
> 	oldflo gets passed in as null and __xfrm_policy_lookup() fails.

No. xdst and oldflo point to same data structure, just to different
offset (and data type). If oldflo is not null, xdst is not either. See
their initialization around lines 1640. Since oldflo is explicitly
tested for not being null, xdst is valid too.

It might make this more obvious if we tested xdst for NULL instead of
oldflo, though.

- Timo

