From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 02 Sep 2016 08:40:15 -0700
Message-ID: <1472830815.5439.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
         <a045ae10-e002-6658-575b-109e66056d5f@cumulusnetworks.com>
         <1472827555.5439.22.camel@edumazet-glaptop3.roam.corp.google.com>
         <94a399f3-72b1-8895-b54f-c7d03878327e@cumulusnetworks.com>
         <1472829718.5439.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36073 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbcIBPkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 11:40:18 -0400
Received: by mail-pf0-f173.google.com with SMTP id h186so43438536pfg.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 08:40:17 -0700 (PDT)
In-Reply-To: <1472829718.5439.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 08:21 -0700, Eric Dumazet wrote:

> Ideally the netdev_rx_handler_register() should be called only when no
> further errors can be detected in the 'enslaving' process, otherwise
> some live packets could come and be incorrectly processed/dropped by a
> not fully initialized driver.
> 
> So it is a chicken and egg problem, if you allow
> netdev_rx_handler_register() to return an error, while it is so easy
> to early check what could go wrong with it.

One final point is that this patch is easy to backport to stable
versions.

bond_enslave() is a monster, and changing the rollback chain is likely
to cause backport merge conflicts.
