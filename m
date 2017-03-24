From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 5/8] net: Track start of busy loop instead
 of when it should end
Date: Thu, 23 Mar 2017 21:38:16 -0700
Message-ID: <1490330296.9687.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
         <20170323213742.12615.85793.stgit@localhost.localdomain>
         <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0Ue+UFOAhwxN-EOjWYZa9YZc2QaT5gvoLap70COs0rF7NA@mail.gmail.com>
         <1490329655.9687.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Linux API <linux-api@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33892 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932085AbdCXEi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 00:38:29 -0400
In-Reply-To: <1490329655.9687.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-23 at 21:27 -0700, Eric Dumazet wrote:

> If you believe min/max values should be added to the sysctls, because we
> do not trust root anymore, please send patches only addressing that. 

extern unsigned int sysctl_net_busy_read;
extern unsigned int sysctl_net_busy_poll;
...
unsigned int            sk_ll_usec;


These are unsigned values, so no min/max would be required, only
maybe use proc_douintvec() instead of proc_dointvec() as most sysctls
use because we were lazy and had to wait linux-4.8 to actually get
proc_douintvec() in the kernel ;)
