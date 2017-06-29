From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 5/9] nfp: extend flower matching capabilities
Date: Thu, 29 Jun 2017 17:31:22 +0300
Message-ID: <CAJ3xEMjoW=JdxEvwtDKU8mBtNEO=_Mdg8kv-jjn2hbDVCA4F6Q@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35905 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753293AbdF2ObY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 10:31:24 -0400
Received: by mail-oi0-f50.google.com with SMTP id p187so67841362oif.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 07:31:24 -0700 (PDT)
In-Reply-To: <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> +       /* Populate IPv4 frame. */
> +       frame->reserved = 0;
> +       frame->ipv4_src = flow_ipv4->src;
> +       frame->ipv4_dst = flow_ipv4->dst;
> +       frame->proto = flow_basic->ip_proto;
> +       /* Wildcard TOS/TTL as TC can't match them yet. */

FWIW this is wrong... matching on both was added recently

> +       frame->tos = 0;
> +       frame->ttl = 0;

note that the same flow dissector matching is used for ipv4 ttl/tos
and ipv6 hoplimit/traffic class
