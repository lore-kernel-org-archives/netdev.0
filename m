From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] sched: cls_flower: remove from hashtable only in
 case skip sw flag is not set
Date: Mon, 28 Nov 2016 22:23:28 +0100
Message-ID: <20161128212328.GD1813@nanopsycho.orion>
References: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
 <CAJ3xEMhdyBfgtOgJqsY_x-Qr6hrhF01nm3VPL-kJnCofA0r3nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amir@vadai.me>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33335 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbcK1VXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:23:32 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so15745472wjc.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:23:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhdyBfgtOgJqsY_x-Qr6hrhF01nm3VPL-kJnCofA0r3nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 28, 2016 at 10:04:56PM CET, gerlitz.or@gmail.com wrote:
>On Mon, Nov 28, 2016 at 4:40 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Be symmetric to hashtable insert and remove filter from hashtable only
>> in case skip sw flag is not set.
>>
>> Fixes: e69985c67c33 ("net/sched: cls_flower: Introduce support in SKIP SW flag")
>
>Amir, Jiri - what was the impact of running without this fix for the
>last 3-4 kernels? I haven't seen any crashes, is that leaking took
>place? or this is just a cleanup to make things more clear and
>maintainable?

It's a fix for real bug. If you add rule with skip_sw flag, it is not
inserted into hashtable. But once you remove it, the current code
removes it from hashtable (did not inspect how rhashtable implementation
handles this).
