From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Oops when insmod rtl8192ce
Date: Wed, 27 Jul 2011 09:37:13 -0500
Message-ID: <4E302299.2070309@lwfinger.net>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com> <CAMzZzFGpDiFAhsLAb+SQxjbGMzBoOStF_Lr7Eb3PT6Drcf=VdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hubert Liao <liao.hubertt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMzZzFGpDiFAhsLAb+SQxjbGMzBoOStF_Lr7Eb3PT6Drcf=VdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/27/2011 04:26 AM, hubert Liao wrote:
> Hi,
> We got an oops when insmod rtl8192ce module (the board is an ARM soc),
> accroding the oops message, find it's because in rtl_pci_probe()
> called _rtl_pci_find_adapter(),
> in this funcation, the  pdev->bus->self is a NULL pointer .
> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>                struct ieee80211_hw *hw)
> {
> struct pci_dev *bridge_pdev = pdev->bus->self;   //line 1601
> ...
> pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor;<--
> [oops here] line 1700
> ...
> }
> here, I just want to know why the bus->self  is NULL?
> ----
> [  148.186632] Unable to handle kernel NULL pointer dereference at
> virtual address 00000020

As John Linville suggested, please open a bugzilla report.

I would also like some additional information. What kernel are you using? In 
addition, please post the 'lspci -nnk' information for your card.

I also think that pdev->bus should have been setup before the initialization 
code in rtl8192ce was called. I have not tested the driver on other than x86 and 
x86_64 architectures because of hardware availability, thus ARM may expose some 
problems. Is this soc little-endian?

Thanks,
Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
