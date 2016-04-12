From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] mwifiex: fix possible NULL dereference
Date: Wed, 13 Apr 2016 01:15:19 +0300
Message-ID: <CAHp75VfACJiVvdtA4Ln9nXq8U7i=7mX17YYq6X-=H3aFS8EyBg@mail.gmail.com>
References: <1460388459-21090-1-git-send-email-sudipm.mukherjee@gmail.com>
	<CAHp75VfO3A+HBjkjc9WC9jzB9gtYrVM6izLmpiqLntChGOzjMA@mail.gmail.com>
	<867653EE-136B-488D-8F85-716B1ED9BD1A@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33377 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbcDLWPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:15:20 -0400
In-Reply-To: <867653EE-136B-488D-8F85-716B1ED9BD1A@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2016 at 8:43 PM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
> Andy Shevchenko <andy.shevchenko@gmail.com> wrote:
>
>> On Mon, Apr 11, 2016 at 6:27 PM, Sudip Mukherjee
>> <sudipm.mukherjee@gmail.com> wrote:
>>>
>>> From: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
>>>
>>> We have a check for card just after dereferencing it. So if it is NULL
>>> we have already dereferenced it before its check. Lets dereference it
>>> after checking card for NULL.

>>> --- a/drivers/net/wireless/marvell/mwifiex/pcie.c
>>> +++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
>>> @@ -2884,10 +2884,11 @@ static void mwifiex_unregister_dev(struct
>>> mwifiex_adapter *adapter)
>>>  {
>>>         struct pcie_service_card *card = adapter->card;>>
>>
>> Let's say it's 0.
>>
>>>        const struct mwifiex_pcie_card_reg *reg;
>>> -       struct pci_dev *pdev = card->dev;>>
>>
>> This would be equal to offset of dev member in pcie_service_card struct.
>>
>> Nothing wrong here.
>
> Actually, that is not true. The dereference of card tells the compiler that
> card can't be NULL, so it is free to eliminate the check below.
> Unbelievably, this can even happen for a reference such as &ptr->thing where
> the pointer isn't even actually dereferenced at all!

Hmm... Can we look at the result assembly? If I'm not mistaken,
compiler wouldn't even try to calculate pdev pointer before first use
of it.


>
>>> +       struct pci_dev *pdev;
>>>         int i;
>>>
>>>         if (card) {
>>> +               pdev = card->dev;
>>>                 if (card->msix_enable) {
>>>                         for (i = 0; i < MWIFIEX_NUM_MSIX_VECTORS; i++)


-- 
With Best Regards,
Andy Shevchenko
