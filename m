From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 15:02:56 -0600
Message-ID: <56F1B300.8070209@cumulusnetworks.com>
References: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
 <56F18EEE.4070000@cumulusnetworks.com>
 <CAM_iQpV6srT84xa4y0WHrKG0mbO2xs=rnKKCx1XB9FtWusxCgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lance Richardson <lrichard@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33319 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcCVVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 17:02:59 -0400
Received: by mail-io0-f176.google.com with SMTP id c63so77786039iof.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 14:02:59 -0700 (PDT)
In-Reply-To: <CAM_iQpV6srT84xa4y0WHrKG0mbO2xs=rnKKCx1XB9FtWusxCgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/16 2:45 PM, Cong Wang wrote:
> @@ -1426,7 +1426,7 @@ int fib_table_lookup(struct fib_table *tb, const
> struct flowi4 *flp,
>                              nh->nh_flags & RTNH_F_LINKDOWN &&
>                              !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
>                                  continue;
> -                       if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
> +                       if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
>                                  if (flp->flowi4_oif &&
>                                      flp->flowi4_oif != nh->nh_oif)
>                                          continue;
>
> For me, it looks the bug was introduce by commit 35ebf65e851c6d9731abc6362b1.
>

Arguably yes since it added the function without initializing flags.

The commit I referenced (and even the VRF predecessor both of which 
originated in the v4.3) is the one introducing use of flow flags to the 
lookup. From a stable perspective going back to v4.3 is what matters.
