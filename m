From: "Ian Brown" <ianbrn@gmail.com>
Subject: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Sun, 25 Nov 2007 16:36:15 +0200
Message-ID: <d0383f90711250636ha8a419emeab52c7107c1d480@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:18880 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbXKYOgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 09:36:17 -0500
Received: by py-out-1112.google.com with SMTP id u77so753863pyb
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2007 06:36:15 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, netdev,

I try, in vain, to understand what is DST_NOHASH for.
I looked for DST_NOHASH under the linux source tree (http://lxr.linux.no/source)
and found that it appears in 4 files:

1) in include/net/dst.h (just defined there, #define DST_NOHASH 8)

2)

in xfrm4_policy.c:
static int
__xfrm4_bundle_create()
{
  ...
  ...
  dst1->flags |= DST_NOHASH;
  ...
  ...
}

3) in net/core/dst.c:
struct dst_entry *dst_destroy(struct dst_entry * dst)
	{
	...
	...	
  int nohash = dst->flags & DST_NOHASH;
	...
	...	
}

4) in Linux/net/ipv6/xfrm6_policy.c


__xfrm6_bundle_create()
 {
  ...
  ...

 else {
                         dst_prev->child = dst1;
                         dst1->flags |= DST_NOHASH;
...
...


}

We see here a definition and 3 places with assignment ; So I don't
understand what is the DST_NOHASH flag for ?
It seems to me that it has to do with IPSec transformers routing tables entires
but again, it seems that this flag is not accessed
(except for assigning this flag).

I would appreciate of anybody will say some words about this flag and its
usage (maybe it is redundant and should be removed?)

Regards,
Ian
