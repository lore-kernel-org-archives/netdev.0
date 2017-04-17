From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Replace constant with sysctl
 netdev_budget_jiffies to enable tuning
Date: Mon, 17 Apr 2017 08:11:34 -0700
Message-ID: <1492441894.10587.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492439349-21081-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Whitehead <tedheadster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33131 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753427AbdDQPLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 11:11:36 -0400
Received: by mail-pf0-f181.google.com with SMTP id s16so67070952pfs.0
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 08:11:36 -0700 (PDT)
In-Reply-To: <1492439349-21081-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 10:29 -0400, Matthew Whitehead wrote:
> Constants used for tuning are generally a bad idea, especially as hardware
> changes over time. Replace the constant '2' with netdev_budget_jiffies to
> enable sysadmins to tune the behavior. Also document the variable.
> 
> For example, a very fast machine might tune this to 1, while my regression
> testing 486DX-25 needs it to be 4 on a nearly idle network to prevent
> time_squeeze from being incremented.

Hi Matthew

What is the problem with this 'time_squeeze' being incremented ?

This is an indicator, but not something bad per se.

Maybe your 486DX-25 should use HZ=100 ;)

Really I do not believe we should let admins/users play with this limit,
they will most likely shoot themselves.

Anyway, exporting in /proc/sys some time limit in 'jiffies' is not
recommended. We prefer portable msecs , usec or nanosec units.

Thanks.
