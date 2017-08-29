From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Tue, 29 Aug 2017 10:47:15 -0600
Message-ID: <55ee348e-3193-f384-b4a9-3f773052a154@gmail.com>
References: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
 <CAOH+1jF3G+Yo30Tk=cgnAPfD8UNe+FkkLjC1uGUd9eeG-ce5KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35256 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbdH2QrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:47:17 -0400
Received: by mail-pf0-f171.google.com with SMTP id g13so11802635pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 09:47:17 -0700 (PDT)
In-Reply-To: <CAOH+1jF3G+Yo30Tk=cgnAPfD8UNe+FkkLjC1uGUd9eeG-ce5KA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/29/17 12:46 AM, Bhumika Goyal wrote:
> I am compile testing them. In this case I did:  make
> net/ipv4/af_inet.o and it compiled. Is this error because of
> typecasting net_protocol inside inet_add_protocol function?

Compile testing is not sufficient. Marking data structures read-only
leaves potential land mines for others to trip over at run-time.

You are making these changes based on a code analysis. Extend the
analysis to elements of the structure. In this case early_demux is the
first element. There are only 9 references to early_demux and cscope
very quickly tells you it can be changed:

7 sysctl_net_ipv4.c proc_configure_early_demux  312 ipprot->early_demux
= enabled ? ipprot->early_demux_handler :
8 sysctl_net_ipv4.c proc_configure_early_demux  318 ip6prot->early_demux
= enabled ? ip6prot->early_demux_handler :
