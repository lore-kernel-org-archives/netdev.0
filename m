From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Tue, 18 Mar 2014 11:07:51 -0700
Message-ID: <CAHA+R7P1DST-f9vJOfJJmjge7ATB8rYMm0XCyuCPUa6VVDpjXg@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:52892 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757018AbaCRSHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:07:52 -0400
Received: by mail-la0-f47.google.com with SMTP id y1so5085016lam.34
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 11:07:51 -0700 (PDT)
In-Reply-To: <OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 9:55 AM, David Stevens <dlstevens@us.ibm.com> wrote:
>
> Wouldn't it be better to:
>
> 1) make sure all of vxlan_dev is initialized before use,
>       especially default_dst
> 2) change the v6 code to check for AF_INET6 too, and do
>       nothing if not set. If not set by the admin, the family of
>       default_dst would then be AF_UNSPEC and not match.
>

Good point! But that needs to change tx path as well, basically
all "if ( sa_family == AF_INET) ... else ...." needs to change
to "if (sa_family == AF_INET) ... else if (==AF_INET6) ... else ...".
