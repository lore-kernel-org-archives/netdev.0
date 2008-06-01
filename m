From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [PATCH v1.2.26] wan: new driver retina
Date: Sun, 1 Jun 2008 08:59:55 +0300
Message-ID: <ca0148c30805312259v4d6a9344le94050ea9295eed8@mail.gmail.com>
References: <ca0148c30805280342l39ffe387rf4c670b17804f99d@mail.gmail.com>
	 <m3prr6obkz.fsf@maximus.localdomain>
	 <ca0148c30805300552u7eb5da43tfc75127a2e819d1@mail.gmail.com>
	 <m3lk1rhio4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:12811 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbYFAF74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 01:59:56 -0400
Received: by wf-out-1314.google.com with SMTP id 27so421208wfd.4
        for <netdev@vger.kernel.org>; Sat, 31 May 2008 22:59:55 -0700 (PDT)
In-Reply-To: <m3lk1rhio4.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/30 Krzysztof Halasa <khc@pm.waw.pl>:
> "Matti Linnanvuori" <mattilinn@gmail.com> writes:
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
> try_module_get(), and that would be fatal.

I don't think the module can finish getting unloaded while in that
function because the module cleanup function unregisters the
character device.

> Yes, I thought stream mode = character device but now I see it's
> another flavour of network device(?), which is never up and exists
> only for the ability to receive netdev ioctls (though it also uses
> char dev ioctls).
>
> Did I get this right?

Yeah.

> Why not simply use a character device, with normal read, write etc?

It would make more sense to use a character device. Read and write
system calls consume more CPU time, though.
