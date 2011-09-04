From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/2] net: Handle different key sizes between address
 families in flow cache
Date: Sun, 4 Sep 2011 17:34:19 +0200
Message-ID: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
References: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg> <1315141641-3120-3-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58453 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab1IDPej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 11:34:39 -0400
Received: by iabu26 with SMTP id u26so5283189iab.19
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2011 08:34:39 -0700 (PDT)
In-Reply-To: <1315141641-3120-3-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/9/4 David Ward <david.ward@ll.mit.edu>:
> With the conversion of struct flowi to a union of AF-specific structs=
, some
> operations on the flow cache need to account for the exact size of th=
e key.
[...]
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
[...]
> +typedef unsigned long flow_compare_t;
> +
> +static inline size_t flowi_size(u16 family)
> +{
> + =A0 =A0 =A0 switch (family) {
> + =A0 =A0 =A0 case AF_INET:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUILD_BUG_ON(sizeof(struct flowi4) % si=
zeof(flow_compare_t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return sizeof(struct flowi4);
> + =A0 =A0 =A0 case AF_INET6:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUILD_BUG_ON(sizeof(struct flowi6) % si=
zeof(flow_compare_t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return sizeof(struct flowi6);
> + =A0 =A0 =A0 case AF_DECnet:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUILD_BUG_ON(sizeof(struct flowidn) % s=
izeof(flow_compare_t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return sizeof(struct flowidn);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}

Since most called user (flow_key_compare) uses returned value didided
by sizeof(flow_compare_t), you could just return divided value here
and save some shift operations by it.

Best Regards,
Micha=B3 Miros=B3aw
