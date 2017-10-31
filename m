From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Subject: Re: [PATCH net-next v3 2/2] net sched act_vlan: VLAN action rewrite
 to use RCU lock/unlock and update
Date: Tue, 31 Oct 2017 13:06:45 +0000
Message-ID: <20171031130645.07c58fdd@pieter-Netronome>
References: <1509266874-17013-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        john.hurley@netronome.com, oss-drivers@netronome.com,
        davem@davemloft.net, netdev@vger.kernel.org, aring@mojatatu.com,
        mrv@mojatatu.com, Manish Kurup <manish.kurup@verizon.com>
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:54757 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdJaNGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 09:06:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id o44so15858600wrf.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 06:06:49 -0700 (PDT)
In-Reply-To: <1509266874-17013-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Oct 2017 04:47:54 -0400
Manish Kurup <kurup.manish@gmail.com> wrote:

> Using a spinlock in the VLAN action causes performance issues when the VLAN
> action is used on multiple cores. Rewrote the VLAN action to use RCU read
> locking for reads and updates instead.
> Fixed nxp flower action to use VLAN helper functions instead of accessing the
> structure directly (build break error).
Thank you Manish. One minor nit, I think you meant nfp flower action...
Also is it possible to split this patch into 2 patches, it seems to do 2 things:
1. Update the VLAN action to use RCU.
2. Fix the nfp flower action to use the VLAN helper.

Can you please dump the build break error you are seeing here?
...
