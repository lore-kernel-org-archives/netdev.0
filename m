From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ip6_tunnel: remove unreachable ICMP_REDIRECT code
Date: Mon, 8 May 2017 13:26:48 -0700
Message-ID: <CAM_iQpWAdKve_ZxG3n+uoz_We65RV95CaKydPFYobo+pQWvjjg@mail.gmail.com>
References: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36358 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752586AbdEHU1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 16:27:10 -0400
Received: by mail-wm0-f45.google.com with SMTP id u65so98030400wmu.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 13:27:09 -0700 (PDT)
In-Reply-To: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 4:11 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> After call ip6_tnl_err(), the rel_type will be ether ICMPV6_DEST_UNREACH
> or ICMPV6_PKT_TOOBIG. We will never reach ICMP_REDIRECT. So remove it.

Are you sure we really don't need to handle NDISC_REDIRECT here?

I can't find anything in RFC 2473 explictly, but I am feeling we should handle
it rather than ignoring it according to:

   To report a problem detected inside the tunnel to the source of an
   original packet, the tunnel entry point node must relay the ICMP
   message received from inside the tunnel to the source of that
   original IPv6 packet.

I am not sure...
