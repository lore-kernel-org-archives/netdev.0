From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 17:35:02 +0900
Message-ID: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be> <20161109.204058.1740541278564630528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: david.lebrun@uclouvain.be,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:38856 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753322AbcKJIfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 03:35:24 -0500
Received: by mail-it0-f44.google.com with SMTP id q124so25532743itd.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 00:35:23 -0800 (PST)
In-Reply-To: <20161109.204058.1740541278564630528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 10:40 AM, David Miller <davem@davemloft.net> wrote:
>
> Series applied, but I wonder if using a Kconfig knob for the INLINE thing
> is overkill.

This breaks IPv6 completely if CONFIG_LWTUNNEL is disabled. When that
happens, seg6_iptunnel_init fails with EOPNOTSUPP and the stack fails
to initialize:

=====
NET: Registered protocol family 10
IPv6: Attempt to unregister permanent protocol 6
IPv6: Attempt to unregister permanent protocol 136
IPv6: Attempt to unregister permanent protocol 17
NET: Unregistered protocol family 10
=====

Not sure how to fix this. The following makes IPv6 work again, but I
suspect it mostly defeats the purpose of having SRH on by default:

+#ifdef CONFIG_LWTUNNEL
         err = seg6_iptunnel_init();
         if (err)
                 goto out_unregister_pernet;
+#endif

Enabling CONFIG_LWTUNNEL also makes IPv6 work again.

The breakage was caught by the kernel test robot, but the message was
not particularly scary:

http://marc.info/?l=linux-netdev&m=147848679207083&w=2
