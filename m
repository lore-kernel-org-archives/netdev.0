From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net] be2net: fix initial MAC setting
Date: Tue, 31 Jan 2017 19:56:05 +0100
Message-ID: <CA+Nub0bj8G8yOOLvt-u3XaE9ftLPYgghPdEDc0yZwGqo4e7Mfg@mail.gmail.com>
References: <20170126102801.18914-1-cera@cera.cz> <CAHHeUGXitTaXqQk8zDymcCX09vFq3CtM20FHJPL6AeVhc2iBPQ@mail.gmail.com>
 <CA+Nub0ZoPT0_k0gnc-d1j_5nK41MkUxt=NX=0Zv3YwtVK964-Q@mail.gmail.com> <20170131.130107.1307753849532001866.davem@davemloft.net>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36050 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdAaS4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:56:07 -0500
Received: by mail-it0-f53.google.com with SMTP id c7so778018itd.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:56:06 -0800 (PST)
In-Reply-To: <20170131.130107.1307753849532001866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-01-31 19:01 GMT+01:00 David Miller <davem@davemloft.net>:
>
>
> Sriharsha and other Broadcom folks, you must follow-up on Ivan's
> explanations and proof of testing.
>
> It is not acceptable for you to leave this patch's review state in
> limbo for days, no matter how complicated or big the patch is.  You
> must at the very least say what you are doing, and how long it will
> take for you to do that before you will be able to fully respond.
>
> Thank you.

Hi Dave,
I have some review notes from them but they have not cc-ed netdev
mailing list. I'm including their comments:

Reply 1:
">> > +
>> > +               /* Delete old programmed MAC if necessary */
>> > +               if (old_pmac_id > 0 && old_pmac_id !=
>> > adapter->pmac_id[0])
>> > +                       be_dev_mac_del(adapter, old_pmac_id);
>>
>> I'm trying to understand why you added the above call to be_dev_mac_del()
>> here.
>> Since be_close() --> be_disable_if_filters() already does this.
>>
> It is necessary, see:
>
> 1) Lets say, we have created BE3 VF... it has programmed MAC1 by PF
> 2) This VF is initially down
> 3) Lets change its MAC address to MAC2. Because the interface is down then
> no programming is done and MAC1 is still active in HW
>     -> adapter->dev_mac = MAC1 and adapter->netdev->dev_addr = MAC2
> 4) Now we set the interface up and be_enable_if_filters() is executed
>    -> dev_mac and dev_addr is different. so MAC2 is programmed by
> be_dev_mac_add()
> 5) Interface is up and has MAC2 as an active MAC
> 6) Lets change active MAC to MAC1
>    -> this will fail if you didn't delete inital MAC1 at step 4

Ok, so this takes care of the case where we do another set-mac without
an intervening interface-down right ? Can you please change the
comment to something like this (drop the "if necessary" since I feel
it is a distraction).

"Delete the old programmed MAC as we successfully programmed a new MAC"

Thanks for the fix, we will update you as soon as we are done with all
our tests tomorrow."

Reply 2:
"I am seeing the collision error with the steps mentioned in your
previous mail. MAC address will not be deleted when old_mac_id is 0.
ZERO (0) is the valid pmac id. So the above check should be >=.

Can you please verify again and fix it.

Regards,
Suresh."

So I will submit v2 with corrected comment and condition check. Btw.
Suresh, Harsha, next time please always cc netdev mailing list. It is
not my responsibility to replicate your emails.

Thanks,
Ivan
