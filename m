From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Test interrupts fail if not all
 comp vectors called request_irq
Date: Mon, 5 Oct 2015 23:12:01 +0300
Message-ID: <CAJ3xEMjjDmezm2UV2_ZiUaOyAREoH3=-m6vzH7RUePR5Jc7MVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	brking@linux.vnet.ibm.com, Amir Vadai <amirv@mellanox.com>
To: Carol Soto <clsoto@linux.vnet.ibm.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34491 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbJEUMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 16:12:01 -0400
Received: by iow1 with SMTP id 1so162197249iow.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 13:12:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 6:24 PM, Carol Soto <clsoto@linux.vnet.ibm.com> wrote:
>
>
> On 10/4/2015 3:03 AM, Or Gerlitz wrote:
>>
>> On 9/29/2015 9:38 PM, clsoto@linux.vnet.ibm.com wrote:
>>>
>>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>
>>> Test interrupts fails if not all completion vectors called
>>> request_irq. This case can happen if only mlx4_en loads and
>>> we have more completion vectors than rx rings.
>>
>>
>> good catch! is this a bug since the driver 0-day or was introduced by
>> some recent commit? in the latercase, please add a Fixes: tag before your
>> S.O.B note.
>
> Probably the issue was introduced by this one
> Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')

Matan, agree to the fix and analysis? if yes, Carol, please add the
Fixes: tag to the change-log
and anyway respin/submit the patch against/for net not net-next

Or.

>
>>>
>>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>> ---
>>>   drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
>>>   1 file changed, 4 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c
>>> b/drivers/net/ethernet/mellanox/mlx4/eq.c
>>> index 8e81e53..c344884 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
>>> @@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
>>>        * and performing a NOP command
>>>        */
>>>       for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
>>> +        /* Make sure request_irq was called */
>>> +        if (!priv->eq_table.eq[i].have_irq)
>>> +            continue;
>>> +
>>>           /* Temporary use polling for command completions */
>>>           mlx4_cmd_use_polling(dev);
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
