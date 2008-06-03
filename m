From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [PATCH v1.2.26] wan: new driver retina
Date: Tue, 3 Jun 2008 15:08:32 +0300
Message-ID: <ca0148c30806030508g23bf0f52r2ac847fcc7cb7cbe@mail.gmail.com>
References: <ca0148c30805280342l39ffe387rf4c670b17804f99d@mail.gmail.com>
	 <m3prr6obkz.fsf@maximus.localdomain>
	 <ca0148c30805300552u7eb5da43tfc75127a2e819d1@mail.gmail.com>
	 <m3lk1rhio4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:51685 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbYFCMId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:08:33 -0400
Received: by py-out-1112.google.com with SMTP id p76so718905pyb.10
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 05:08:32 -0700 (PDT)
In-Reply-To: <m3lk1rhio4.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/30 Krzysztof Halasa <khc@pm.waw.pl>:
> "Matti Linnanvuori" <mattilinn@gmail.com> writes:
>
>> I would not like to change a legacy driver much.
>
> But this is a new driver, right? I guess the SIOCDEVPRIVATEs will go
> at some point so the change can't be really avoided.

I posted retina-1.2.29.patch that does not have SIOCDEVPRIVATEs at
http://groups.google.com/group/pcidriver/files.

>>>> +static int fepci_char_open(struct inode *inode, struct file *filp)
>>>> +{
>>>> +     unsigned int minor = MINOR(inode->i_rdev);
>>>> +     if (unlikely(minor >= find_cnt || card_privates[minor].pci_dev == NULL))
>>>> +             return -ENXIO;
>>>> +     filp->f_op = &fepci_char_fops;
>>>> +     if (unlikely(!try_module_get(THIS_MODULE)))
>>>> +             return -EBUSY;
>>>
>>> That won't work race-free, use owner field.
>>
>> You mean the f_op assignment? I have removed that.
>
> Actually I meant try_module_get() from within the driver, for example
> your module may get unloaded while in this function, before this
> try_module_get(), and that would be fatal. If you set the owner field
> the reference count will be incremented by the caller first.

I added the owner field setting to the above mentioned patch.
