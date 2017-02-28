From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 16:14:04 -0800
Message-ID: <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34188 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751665AbdB1CD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 21:03:29 -0500
Received: by mail-pf0-f180.google.com with SMTP id p185so12126909pfb.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 18:03:00 -0800 (PST)
In-Reply-To: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/17 4:07 PM, Cong Wang wrote:
> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
> because ip6_null_entry is returned in this path since ip6_null_entry
> is kinda default for a ipv6 route table root node. Quote from


Missed this earlier. The issue here is an attempt to delete the NULL
route, not that the null_entry is being returned as happens during a
route lookup. This will also hit the bug:
    ip -6 ro del ::/0
