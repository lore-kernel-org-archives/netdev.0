From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Wed, 2 Nov 2016 09:10:32 -0600
Message-ID: <2a540f59-4495-573c-7dda-0303f1810e6e@cumulusnetworks.com>
References: <20161102123630.784612652@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34488 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752434AbcKBPKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:10:35 -0400
Received: by mail-pf0-f182.google.com with SMTP id n85so13559494pfi.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:10:35 -0700 (PDT)
In-Reply-To: <20161102123630.784612652@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 6:36 AM, Cyrill Gorcunov wrote:
> Also I have a question about sockets lookup not for raw diag only
> (though I didn't modify lookup procedure) but in general: the structure
> inet_diag_req_v2 has inet_diag_sockid::idiag_if member which supposed to
> carry interface index from userspace request.
> 
> Then for example in INET_MATCH (include/net/inet_hashtables.h),
> the __dif parameter (which is @idiag_if) compared with @sk_bound_dev_if
> *iif* the sk_bound_dev_if has been ever set. Thus if say someone
> looks up for paticular device with specified index if the
> rest of parameters match and SO_BINDTODEVICE never been called
> for this device we return the socket even if idiag_if is not zero.
> Is it supposed to be so? Or I miss something obvious?
> 
> I mean this snippet
> 
> 
> 	 (!(__sk)->sk_bound_dev_if	||				\
> 	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
> 
> when someone calls for destory sockets on particular interface and
> @__dif != 0 the match may return socket where sk_bound_dev_if = 0
> instead of completely matching one. Isn't it?

yes. I recently added an exact_dif to the lookup for listener sockets (see compute_score). Something like that could be added to INET_MATCH.
