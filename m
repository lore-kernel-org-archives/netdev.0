From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH] p54pci: don't return zero on failure path in p54p_probe()
Date: Wed, 02 Jan 2013 02:44:38 +0400
Message-ID: <50E366D6.7040709@ispras.ru>
References: <1357074661-15784-1-git-send-email-khoroshilov@ispras.ru> <201301012245.43064.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201301012245.43064.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/02/2013 01:45 AM, Christian Lamparter wrote:
> On Tuesday 01 January 2013 22:11:01 Alexey Khoroshilov wrote:
>> If pci_set_dma_mask() or pci_set_consistent_dma_mask() fails in p54p_probe(),
>> it breaks off initialization, deallocates all resources, but returns zero.
>>
>> The patch implements proper error code propagation.
> Uh, Thanks!
>
> But wait, I think there's another return 0 in the error
> path. See p54pci.c @ line 558:
>
> mem_len = pci_resource_len(pdev, 0);
> if (mem_len < sizeof(...)) {
> 	dev_err(...)
> 	goto err_disabled_dev;
> }
>
> Do you think you can add a err = -EINVAL; before the goto too?
You are right! But I would say -ENODEV is more popular error code in 
this case.
> [I wonder why this wasn't found by the verification project as
> well? Could it be that pci_resource_len(...) < sizeof(...) is
> somehow always true and this is a dead branch?]
Actually it was found, but I have no direct access to the results at the 
moment. My fault.

Would you like I resend the patch to fix both?

--
Best regards,
Alexey

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
