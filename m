From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 02 Sep 2016 06:33:20 -0700
Message-ID: <1472823200.5439.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
         <20160902075241.GA1814@nanopsycho>
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34299 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcIBNdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:33:23 -0400
Received: by mail-pf0-f178.google.com with SMTP id p64so42629634pfb.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 06:33:23 -0700 (PDT)
In-Reply-To: <20160902075241.GA1814@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 09:52 +0200, Jiri Pirko wrote:

> 
> No, please, don't make bonding a spacial citizen introducing this.
> Please handle the issue inside the bonding code, like we do for the rest
> of master devices (and how it was once done for bonding). Thanks.

I do not feel this netdev_is_rx_handler_busy() use is special to
bonding.

It makes sense to use it early, to avoid complex rollback, once various
events have been sent all over.

bond_enslave() is 447 lines long already.

You perfectly know how hard it is to 'handle the issue inside the
bonding code' as you chose to not fix bonding and write team instead.

So Mahesh patch makes perfect sense to me. It exactly fixes a stupid
bond_enslave() behavior, trying to set rx_handler way too late.

By doing sanity checks before any action, we simply do not have to add
complex rollback.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
