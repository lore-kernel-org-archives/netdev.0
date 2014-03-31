From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 3/5] bonding: Initialize the ALB work queue for lb mode only.
Date: Mon, 31 Mar 2014 15:00:18 -0700
Message-ID: <CAF2d9jjKO7duHg89Vth8T5464HMK0tZzSdwbfRsuSwVCDQB1Ag@mail.gmail.com>
References: <1396070946-17650-1-git-send-email-maheshb@google.com>
 <1396280940.29410.38.camel@edumazet-glaptop2.roam.corp.google.com>
 <5848.1396283241@famine> <1396284040.29410.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:55678 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaCaWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 18:00:39 -0400
Received: by mail-vc0-f172.google.com with SMTP id la4so8895668vcb.31
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 15:00:39 -0700 (PDT)
In-Reply-To: <1396284040.29410.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 9:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-03-31 at 09:27 -0700, Jay Vosburgh wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> >On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
>> >> micro change to initialize / cancel the ALB work queue only
>> >> if the mode selected is ALB or TLB.
>> >>
>> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> >> ---
>> >
>> >Can the mode of a bonding device be dynamically changed ?
>>
>>       No.  The mode can only be changed when there are no slaves in
>> the bond, and the bond is administratively down.
>
> I don't see why this patch is needed.
>
> What about mii_work, arp_work ?
>
I was focusing on the lb mode only at this time.

> There is no cost calling INIT_DELAYED_WORK(&bond->alb_work,
> bond_alb_monitor) and cancel_delayed_work_sync(&bond->alb_work)
>
Why even bother initialize if we know *for sure* we are not going to
use it. In subsequent patch though the work queue may or may not be
needed based on the tlb_dynamic_mode selected. That's when I though we
should *only* enabled it in the mode that is relevant.

>
>
>
>
