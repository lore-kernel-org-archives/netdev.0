From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Replace 2 jiffies with sysctl
 netdev_budget_usecs to enable softirq tuning
Date: Fri, 21 Apr 2017 12:57:02 -0700
Message-ID: <1492804622.6453.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492619830-7561-1-git-send-email-tedheadster@gmail.com>
         <20170421.132245.1207278487695293623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35943 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425794AbdDUT5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:57:05 -0400
Received: by mail-oi0-f65.google.com with SMTP id a3so17712885oii.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:57:05 -0700 (PDT)
In-Reply-To: <20170421.132245.1207278487695293623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 13:22 -0400, David Miller wrote:
> From: Matthew Whitehead <tedheadster@gmail.com>
> Date: Wed, 19 Apr 2017 12:37:10 -0400
> 
> > Constants used for tuning are generally a bad idea, especially as hardware
> > changes over time. Replace the constant 2 jiffies with sysctl variable
> > netdev_budget_usecs to enable sysadmins to tune the softirq processing.
> > Also document the variable.
> > 
> > For example, a very fast machine might tune this to 1000 microseconds,
> > while my regression testing 486DX-25 needs it to be 4000 microseconds on
> > a nearly idle network to prevent time_squeeze from being incremented.
> > 
> > Version 2: changed jiffies to microseconds for predictable units.
> > 
> > Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
> 
> Applied, thanks.

Can we revert the changes in kernel/sysctl_binary.c &
include/uapi/linux/sysctl.h ?

{ CTL_INT,      NET_CORE_BUDGET_USECS,  "netdev_budget_usecs" },

NET_CORE_BUDGET_USECS=23,

Unless I am missing something, we should not add new binary sysctls.


Thanks.
