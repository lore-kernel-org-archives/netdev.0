From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: BROKEN Re: [PATCH] netlink: 2-clause nla_ok()
Date: Mon, 5 Dec 2016 17:56:26 +0300
Message-ID: <CACVxJT9Qc=vNexx4ooQVFo=SrGs4-oHeZrnL18vbiS+o0F_N1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f172.google.com ([209.85.210.172]:34557 "EHLO
        mail-wj0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751485AbcLEO4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:56:51 -0500
Received: by mail-wj0-f172.google.com with SMTP id tg4so37454011wjb.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:56:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, please do

    git revert 4f7df337fe79bba1e4c2d525525d63b5ba186bbd

I'm an idiot.

All rationale in the commit would be correct if reading "nla_len"
didn't require memory access. But it does.

    return rem >= (int)sizeof(*nla) &&
               nla->nla_len >= sizeof(*nla) &&
               nla->nla_len <= remaining;

Those logical ands ensure that memory access is not done
if "rem" is small enough to even fetch ->nla_len.

Maybe someone could vouch that other checks prevent
this kind of situation from happening but not me.
How very embarrassing.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
