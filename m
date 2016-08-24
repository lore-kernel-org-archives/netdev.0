From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] net: diag: allow socket bytecode filters
 to match socket marks
Date: Wed, 24 Aug 2016 08:35:12 -0600
Message-ID: <77441548-8f56-08de-4b76-00ed404a6ffe@cumulusnetworks.com>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
 <1472021186-4106-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net, ek@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33122 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754245AbcHXOfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 10:35:14 -0400
Received: by mail-pf0-f178.google.com with SMTP id y134so7490389pfg.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 07:35:14 -0700 (PDT)
In-Reply-To: <1472021186-4106-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 12:46 AM, Lorenzo Colitti wrote:
> This allows a privileged process to filter by socket mark when
> dumping sockets via INET_DIAG_BY_FAMILY. This is useful on
> systems that use mark-based routing such as Android.
> 
> The ability to filter socket marks requires CAP_NET_ADMIN, which
> is consistent with other privileged operations allowed by the
> SOCK_DIAG interface such as the ability to destroy sockets and
> the ability to inspect BPF filters attached to packet sockets.

sock_diag_destroy already requires ADMIN for destroying sockets, so adding here just prevents listing them. Given that and the fact that the diag API does not pass the mark value is there a reason to add the extra ADMIN check?
 
