From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/2] fib4 offload: notifier to let hw to be
 aware of all prefixes
Date: Sun, 18 Sep 2016 13:00:44 -0700
Message-ID: <fc177125-a9b8-fcce-281b-5fdc25639944@gmail.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@intel.com, andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34280 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbcIRUAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:00:49 -0400
Received: by mail-oi0-f65.google.com with SMTP id v62so7012868oig.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 13:00:48 -0700 (PDT)
In-Reply-To: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2016 à 05:01, Jiri Pirko a écrit :
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This is RFC, unfinished. I came across some issues in the process so I would
> like to share those and restart the fib offload discussion in order to make it
> really usable.
> 
> So the goal of this patchset is to allow driver to propagate all prefixes
> configured in kernel down HW. This is necessary for routing to work
> as expected. If we don't do that HW might forward prefixes known to kernel
> incorrectly. Take an example when default route is set in switch HW and there
> is an IP address set on a management (non-switch) port.
> 
> Currently, only fibs related to the switch port netdev are offloaded using
> switchdev ops. This model is not extendable so the first patch introduces
> a replacement: notifier to propagate fib additions and removals to whoever
> interested. The second patch makes mlxsw to adopt this new way, registering
> one notifier block for each mlxsw (asic) instance.

Instead of introducing another specialization of a notifier_block
implementation, could we somehow have a kernel-based netlink listener
which receives the same kind of event information from rtmsg_fib()?

The reason is that having such a facility would hook directly onto
existing rtmsg_* calls that exist throughout the stack, and that seems
to scale better.
-- 
Florian
