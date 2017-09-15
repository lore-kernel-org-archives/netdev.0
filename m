From: Srishti Sharma <srishtishar@gmail.com>
Subject: Re: [Outreachy kernel] [PATCH] Staging: irda: Don't use assignment
 inside if statement
Date: Sat, 16 Sep 2017 01:12:01 +0530
Message-ID: <CAB3L5ozymEpGYLqH88xZrfQBjDsCdO0yCJYLCFCiYDRXh8E2qg@mail.gmail.com>
References: <1505504036-21807-1-git-send-email-srishtishar@gmail.com>
 <alpine.DEB.2.20.1709152136200.2533@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, samuel@sortiz.org,
 Greg KH <gregkh@linuxfoundation.org>,
 Linux kernel mailing list <linux-kernel@vger.kernel.org>,
 outreachy-kernel@googlegroups.com, netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <alpine.DEB.2.20.1709152136200.2533@hadrien>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Sat, Sep 16, 2017 at 1:08 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
> On Sat, 16 Sep 2017, Srishti Sharma wrote:
>
>> Write assignment statement outside the if statement. Done using
>> the following semantic patch by coccinelle.
>>
>> @@
>> identifier E;
>> expression F;
>> statement S;
>> @@
>>
>> -if((E = F))
>> +E = F
>
> The line above would need to end in a ;
Yes, I'll send a v2 after correcting it .
>
> This ends up with a lot of assignments with () around the right hand side.
> Maybe you could make a series removing them afterwards.
Yes, I'll do that . Thanks .

Regards,
Srishti
>
> julia
>
>> +if(E)
>>   S
>>
>> Signed-off-by: Srishti Sharma <srishtishar@gmail.com>
>> ---
>>  drivers/staging/irda/drivers/irda-usb.c | 4 ++--
>>  drivers/staging/irda/drivers/mcs7780.c  | 9 ++++++---
>>  drivers/staging/irda/net/irqueue.c      | 3 ++-
>>  3 files changed, 10 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/staging/irda/drivers/irda-usb.c b/drivers/staging/irda/drivers/irda-usb.c
>> index 723e49b..82bfc05 100644
>> --- a/drivers/staging/irda/drivers/irda-usb.c
>> +++ b/drivers/staging/irda/drivers/irda-usb.c
>> @@ -334,9 +334,9 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
>>       urb->transfer_flags = 0;
>>
>>       /* Irq disabled -> GFP_ATOMIC */
>> -     if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
>> +     ret = usb_submit_urb(urb, GFP_ATOMIC);
>> +     if (ret)
>>               net_warn_ratelimited("%s(), failed Speed URB\n", __func__);
>> -     }
>>  }
>>
>>  /*------------------------------------------------------------------*/
>> diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
>> index c3f0b25..2b674d5 100644
>> --- a/drivers/staging/irda/drivers/mcs7780.c
>> +++ b/drivers/staging/irda/drivers/mcs7780.c
>> @@ -605,19 +605,22 @@ static int mcs_speed_change(struct mcs_cb *mcs)
>>       if (mcs->new_speed <= 115200) {
>>               rval &= ~MCS_FIR;
>>
>> -             if ((rst = (mcs->speed > 115200)))
>> +             rst = (mcs->speed > 115200);
>> +             if (rst)
>>                       mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);
>>
>>       } else if (mcs->new_speed <= 1152000) {
>>               rval &= ~MCS_FIR;
>>
>> -             if ((rst = !(mcs->speed == 576000 || mcs->speed == 1152000)))
>> +             rst = !(mcs->speed == 576000 || mcs->speed == 1152000);
>> +             if (rst)
>>                       mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
>>
>>       } else {
>>               rval |= MCS_FIR;
>>
>> -             if ((rst = (mcs->speed != 4000000)))
>> +             rst = (mcs->speed != 4000000);
>> +             if (rst)
>>                       mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
>>
>>       }
>> diff --git a/drivers/staging/irda/net/irqueue.c b/drivers/staging/irda/net/irqueue.c
>> index 160dc89..5aab072 100644
>> --- a/drivers/staging/irda/net/irqueue.c
>> +++ b/drivers/staging/irda/net/irqueue.c
>> @@ -217,7 +217,8 @@ static __u32 hash( const char* name)
>>
>>       while(*name) {
>>               h = (h<<4) + *name++;
>> -             if ((g = (h & 0xf0000000)))
>> +             g = (h & 0xf0000000);
>> +             if (g)
>>                       h ^=g>>24;
>>               h &=~g;
>>       }
>> --
>> 2.7.4
>>
>> --
>> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
>> To post to this group, send email to outreachy-kernel@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1505504036-21807-1-git-send-email-srishtishar%40gmail.com.
>> For more options, visit https://groups.google.com/d/optout.
>>
