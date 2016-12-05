From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management frames to CPU
Date: Sun, 04 Dec 2016 19:23:45 -0500
Message-ID: <87inqzcjfy.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch> <1480736720-12608-2-git-send-email-andrew@lunn.ch> <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161204202234.GA20743@lunn.ch> <87oa0r9wei.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161204224054.GA24118@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44754 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLEAYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 19:24:48 -0500
In-Reply-To: <20161204224054.GA24118@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> You can have several implementations in the same file (e.g. global1.c),
>> so again the only value is the function name, not the struct member.
>
> The structure member have g1_ has a lot of value.
>
>         if (chip->info->ops->set_cpu_port) {
>                 err = chip->info->ops->set_cpu_port(chip, upstream_port);
>                 if (err)
>                         return err;
>         }
>
> Where to i need to go look for set_cpu_port? I have no idea.

In your chip's ops definition, as for any ops structure. Same as for
your example right below which is unfortunately not a solution per-se.

>
>         if (chip->info->ops->g1_set_cpu_port) {
>                 err = chip->info->ops->g1_set_cpu_port(chip, upstream_port);
>                 if (err)
>                         return err;
>         }
>
> Humm, the hint tells me it is in global1.c. And i also know that all
> of them are in global1.c.

Until a new chip relocates a feature somewhere else.

Then you'll have to rename the structure member(s) because you have a
policy saying "no prefix means different set of registers".


       Vivien
