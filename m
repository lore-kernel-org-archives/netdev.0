From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Tue, 07 Mar 2017 08:56:53 -0800
Message-ID: <1488905813.9415.403.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
         <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
         <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170307082946.72a7520a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel J Blueman <daniel@quora.org>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34718 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754182AbdCGQ6G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 11:58:06 -0500
Received: by mail-pg0-f53.google.com with SMTP id 77so2497654pgc.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 08:56:55 -0800 (PST)
In-Reply-To: <20170307082946.72a7520a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-07 at 08:29 -0800, Stephen Hemminger wrote:

> +       WARN_ONCE(strcmp(default_qdisc_ops->id, "fq"),
> +                 "TCP BBR should only be used with FQ qdisc\n");
> +
>  

Why would that be needed, especially for people that properly setup
their qdisc ? Maybe they do not want to force fq on all devices like tun
or taps ;)

Also we intend to provide a fallback in case FQ is not in the qdisc
chain : Some routers admins really want fq_codel (or whatever qdisc)

TCP will handle the pacing itself, at a small cost for the ones that
hate fq.
