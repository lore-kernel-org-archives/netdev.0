From: "Ian Brown" <ianbrn@gmail.com>
Subject: RTF_DYNAMIC flag in ipv4 and in ipv6 , ICMP redirect and the routing table/cache
Date: Tue, 19 Jun 2007 18:16:05 +0300
Message-ID: <d0383f90706190816l77d76634j33573ea125514499@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:38826 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbXFSPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:16:06 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1778378nzf
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 08:16:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Suppose a routing cache entry is added as a consequence of
a redirect to host ICMP message.

There is in include/linux.h two flags , one for entry which
is created and one for an entry which is modified because of a redirect:

#define RTF_DYNAMIC     0x0010          /* created dyn. (by redirect) */
#define RTF_MODIFIED    0x0020          /* modified dyn. (by redirect)

Let's talk about the first case , creation of an entry as a result of redirect.
(RTF_DYNAMIC).

I saw that  the RTF_DYNAMIC flag is used only in ipv6 (in
net/ipv6/route.c, in rt6_redirect() method.

MY question is : why is this flag not set in ipv4 redirect method  ?
(ip_rt_redirect() in route.c).

As far as I understand, because this flag is **not** set in ipv4, there is no
way to know that a route was changed by a redirect (not in the route cache
and not in the routing table (fib_table).

The reason for this is, that from "man route" you can see that the
flags possible when redirect occurs are:
ute for dynamic routing)
              D (dynamically installed by daemon or redirect)
              M (modified from routing daemon or redirect)

D corresponds to RTF_DYNAMIC and M corresponds to RTF_MODIFIED.

I know that many machines are not accepting redirects by default
from reasons of security. Yet it seems to me stange, that as a result of
what was explained above, there is no way to know in ipv4 that a route was
changed as a result of host redirect (yet it is possible as far as I understand
to know it in ipv6).

Any explanations/clarifications?

Regards,
IB
