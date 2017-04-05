From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Tue, 4 Apr 2017 23:02:38 -0700
Message-ID: <b59025eb-e653-8481-2e58-a780777df4ee@gmail.com>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
 <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
 <1491371595.4166.77.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33518 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdDEGCl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 02:02:41 -0400
Received: by mail-oi0-f53.google.com with SMTP id b187so3880395oif.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 23:02:41 -0700 (PDT)
In-Reply-To: <1491371595.4166.77.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/04/2017 10:53 PM, Benjamin Herrenschmidt wrote:
> On Tue, 2017-04-04 at 21:21 -0700, Florian Fainelli wrote:
>>
>> This looks pretty good to me, two minor things:
>>
>> - most drivers keep track of the old status/duplex/pause/link variables
>> instead of the current one which is already available within struct
>> phy_device, any particular reason for not doing like the other drivers?
> 
> We don't necessarily have a phydev attached when using NC-SI, so it was
> easier to have the core code path not have to go fishing for those
> settings in different places based on whether we're using NC-SI or not.

Oh right, I missed that part. Is there a reason why NC-SI does not have
a PHY device attached? If not, could you somehow model the link using a
fixed PHY (which appears to Linux as a normal phy_device) just to keep
things simple.

> 
>> - the need to reset the HW during link changes is just ... well too bad
> 
> Yup but there's little choice. The HW wants it. I don't see any real
> point in optimizing that path mind you. Losing a few packets around
> a link change isn't going to hurt and it keeps the code a lot simpler
> by having a single "re-init" path.

I was just merely trying to say nicely: what a nicely broken piece of HW
(there were other adjectives coming to mind), and I do understand the pain.

> 
>> With that:
>>
>>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Thanks !
> 
> I'll post batch 2 in the next couple of days which tackles the RX path.

Cool, looking forward to that!
-- 
Florian
