From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH next 0/4] bonding: winter cleanup
Date: Wed, 22 Feb 2017 08:58:15 +0100
Message-ID: <20170222075815.GA1665@nanopsycho>
References: <20170222010816.9676-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35154 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753309AbdBVH6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 02:58:19 -0500
Received: by mail-wm0-f67.google.com with SMTP id u63so860829wmu.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 23:58:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170222010816.9676-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 22, 2017 at 02:08:16AM CET, mahesh@bandewar.net wrote:
>From: Mahesh Bandewar <maheshb@google.com>
>
>Few cleanup patches that I have accumulated over some time now.
>
>(a) First two patches are basically to move the work-queue initialization
>    from every ndo_open / bond_open operation to once at the beginning while
>    port creation. Work-queue initialization is an unnecessary operation
>    for every 'ifup' operation. However we have some mode-specific work-queues
>    and mode can change anytime after port creation. So the second patch is
>    to ensure the correct work-handler is called based on the mode.
>
>(b) Third patch is simple and straightforward that removes hard-coded value
>    that was added into the initial commit and replaces it with the default
>    value configured.
>
>(c) The final patch in the series removes the unimplemented "port-moved" state
>    from the LACP state machine. This state is defined but never set so
>    removing from the state machine logic makes code little cleaner.
>
>Note: None of these patches are making any functional changes.
>
>Mahesh Bandewar (4):

Mahesh. I understand that you are still using bonding. What's stopping
you from using team instead?

Isn't about the time to start deprecate process of bonding? :O


>  bonding: restructure arp-monitor
>  bonding: initialize work-queues during creation of bond
>  bonding: remove hardcoded value
>  bonding: remove "port-moved" state that was never implemented
>
> drivers/net/bonding/bond_3ad.c  | 11 +++--------
> drivers/net/bonding/bond_main.c | 42 ++++++++++++++++++++++++++++-------------
> 2 files changed, 32 insertions(+), 21 deletions(-)
>
>-- 
>2.11.0.483.g087da7b7c-goog
>
