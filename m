From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 2 Sep 2016 18:25:13 +0200
Message-ID: <20160902162513.GA1768@nanopsycho.orion>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
 <20160902075241.GA1814@nanopsycho>
 <1472823200.5439.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38459 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932805AbcIBQZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:25:18 -0400
Received: by mail-wm0-f48.google.com with SMTP id 1so39909388wmz.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:25:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472823200.5439.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 02, 2016 at 03:33:20PM CEST, eric.dumazet@gmail.com wrote:
>On Fri, 2016-09-02 at 09:52 +0200, Jiri Pirko wrote:
>
>> 
>> No, please, don't make bonding a spacial citizen introducing this.
>> Please handle the issue inside the bonding code, like we do for the rest
>> of master devices (and how it was once done for bonding). Thanks.
>
>I do not feel this netdev_is_rx_handler_busy() use is special to
>bonding.
>
>It makes sense to use it early, to avoid complex rollback, once various
>events have been sent all over.
>
>bond_enslave() is 447 lines long already.
>
>You perfectly know how hard it is to 'handle the issue inside the
>bonding code' as you chose to not fix bonding and write team instead.
>
>So Mahesh patch makes perfect sense to me. It exactly fixes a stupid
>bond_enslave() behavior, trying to set rx_handler way too late.
>
>By doing sanity checks before any action, we simply do not have to add
>complex rollback.

Understand the reason. All I say is we tried hard (I surely did) in
the past to remove bonding specific quirks and now we are adding one.
And the simple reason is that the code is such a mess.

Just use team instead and you'll be fine. You can "google" it :)
