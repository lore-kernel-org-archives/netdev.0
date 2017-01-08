From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/2] net: dsa: bcm_sf2: Do not clobber b53_switch_ops
Date: Sun, 8 Jan 2017 11:31:05 -0800
Message-ID: <37a65faf-93f1-067a-cd85-55d96b0631cc@gmail.com>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
 <20170108050157.16302-2-f.fainelli@gmail.com>
 <20170108174105.GA21101@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34953 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750891AbdAHTbI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 14:31:08 -0500
Received: by mail-oi0-f68.google.com with SMTP id x84so10359363oix.2
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 11:31:08 -0800 (PST)
In-Reply-To: <20170108174105.GA21101@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/08/17 à 09:41, Andrew Lunn a écrit :
> On Sat, Jan 07, 2017 at 09:01:56PM -0800, Florian Fainelli wrote:
>> We make the bcm_sf2 driver override ds->ops which points to
>> b53_switch_ops since b53_switch_alloc() did the assignent. This is all
>> well and good until a second b53 switch comes in, and ends up using the
>> bcm_sf2 operations. Make a proper local copy, substitute the ds->ops
>> pointer and then override the operations.
>>
>> Fixes: f458995b9ad8 ("net: dsa: bcm_sf2: Utilize core B53 driver when possible")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Hi Florian

Hi Andrew,

> 
> There is a general trend of making ops structures const. It closes off
> kernel exploits. This coping and then modifying prevents us making
> ds->ops a pointer to a const.

Agreed, and this was my initial approach, but I also wanted a minimal
fix for David to pull into "net" while we can properly resolve this for
"net-next" see below.

> 
> You are already using b53_common.c as a library. Could you go further
> with the concept, and export the ops you need for SF2, and have SF2
> define its own ops structure? We can then swap to const ops dsa wide.

Making the ops const was my initial approach but there are several
challenges to making it possible right now which I will address against
net-next:

- register/unregister_switch_driver actually do modify dsa_switch_ops
while updating the list pointer, so we need to encapsulate
dsa_switch_ops into a dsa_switch_driver plus a list member

- as you pointed out, b53 needs to export the operations to other
drivers that are going to make use of them

Thanks for your comments!
-- 
Florian
