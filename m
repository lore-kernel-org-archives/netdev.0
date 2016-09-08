From: Jojy Varghese <jojy.varghese@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 8 Sep 2016 15:12:47 -0700
Message-ID: <CAJD3hpWs7ur8qc+E3yq_oJWs7NdbJEmRrxKFesYbap9ihSzUiw@mail.gmail.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
 <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
 <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com> <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35934 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932233AbcIHWMu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 18:12:50 -0400
Received: by mail-wm0-f68.google.com with SMTP id l65so143721wmf.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 15:12:49 -0700 (PDT)
In-Reply-To: <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric/Lance

 Thanks for taking time to look at the patch. The problem in dst.c's
"dst_ifdown" is that it will never do an actual "dev_put" on the
loopback net device. This results in the loopback net device to be
alive even when the dst goes away.

Thanks
Jojy

On Thu, Sep 8, 2016 at 2:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-09-08 at 14:00 -0700, Eric Dumazet wrote:
>
>> Latest real fix was :
>> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=751eb6b6042a596b0080967c1a529a9fe98dac1d
>
> Another interesting fix is
>
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=a5d0dc810abf3d6b241777467ee1d6efb02575fc
>
>
>



-- 
Jojy G Varghese
