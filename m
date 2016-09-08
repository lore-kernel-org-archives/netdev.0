From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 15:16:52 -0700
Message-ID: <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
         <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
         <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpWs7ur8qc+E3yq_oJWs7NdbJEmRrxKFesYbap9ihSzUiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36478 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbcIHWQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 18:16:55 -0400
Received: by mail-pf0-f194.google.com with SMTP id x24so3021999pfa.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 15:16:55 -0700 (PDT)
In-Reply-To: <CAJD3hpWs7ur8qc+E3yq_oJWs7NdbJEmRrxKFesYbap9ihSzUiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 15:12 -0700, Jojy Varghese wrote:
> Hi Eric/Lance
> 
>  Thanks for taking time to look at the patch. The problem in dst.c's
> "dst_ifdown" is that it will never do an actual "dev_put" on the
> loopback net device. This results in the loopback net device to be
> alive even when the dst goes away.

Sure, but the dst themselves should disappear, and thus release their
dst->dev reference.

Something is missing.

loopback device is only used when we remove one device from the system,
but namespace (and loopback device) is still around.
