From: James Chapman <jchapman@katalix.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Mon, 2 Oct 2017 14:32:20 +0100
Message-ID: <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:52182 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdJBNmB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 09:42:01 -0400
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
        (Authenticated sender: james)
        by mail.katalix.com (Postfix) with ESMTPSA id 791B5A86AE
        for <netdev@vger.kernel.org>; Mon,  2 Oct 2017 14:32:22 +0100 (BST)
Received: by mail-pf0-f172.google.com with SMTP id m63so2898571pfk.7
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 06:32:22 -0700 (PDT)
In-Reply-To: <20171001102110.24184f1b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems to be a NULL pointer exception caused by tunnel->sock being
NULL at the call to bh_lock_sock() in l2tp_xmit_skb() at
l2tp_core.c:1135.

tunnel->sock is set NULL in l2tp_core's tunnel socket destructor.

At the moment, I don't understand how this happens because
pppol2tp_xmit() does a sock_hold() on the tunnel socket before
l2tp_xmit_skb() is called. I'm still looking at this.

Has this problem only recently started happening?





On 1 October 2017 at 18:21, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Sun, 01 Oct 2017 16:22:33 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=197099
>
>             Bug ID: 197099
>            Summary: Kernel panic in interrupt [l2tp_ppp]
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.8.13-1.el6.elrepo.x86_64
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: stephen@networkplumber.org
>           Reporter: svimik@gmail.com
>         Regression: No
>
> Created attachment 258685
>   --> https://bugzilla.kernel.org/attachment.cgi?id=258685&action=edit
> stacktrace screenshot
>
> Hello!
>
> Getting kernel panics on multiple servers. Since it mentions l2tp_core,
> l2tp_ppp and ppp_generic, I decided to report it to Networking (correct me if
> I'm wrong).
>
> Unfortunately I'm still struggling with making kdump work, so the trace
> screenshot is all I have at this moment. The only hope is that this stacktrace
> means something to the guys that wrote the code.
>
> --
> You are receiving this mail because:
> You are the assignee for the bug.
