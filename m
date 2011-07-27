From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Oops when insmod rtl8192ce
Date: Wed, 27 Jul 2011 09:53:53 -0400
Message-ID: <20110727135353.GA16431@tuxdriver.com>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hubert Liao <liao.hubertt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2011 at 05:20:15PM +0800, hubert Liao wrote:
> Hi,
> 
> We got an oops when insmod rtl8192ce module (the board is an ARM soc),
> accroding the oops message, find it's because in rtl_pci_probe() called
> _rtl_pci_find_adapter(),
> in this funcation, the  pdev->bus->self is a NULL pointer .
> 
> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>               struct ieee80211_hw *hw)
> {
> 
> struct pci_dev *bridge_pdev = pdev->bus->self;   //line 1601
> ...
> 
> pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor; <-- [oops
> here] line 1700
> 
> ...
> }
> 
> here, I just want to know why the bus->self  is NULL?

pdev is coming straight from what is passed to the PCI probe routine.
It seems like pdev->bus->self should already be set before that
happens.

Please open a bug at bugzilla.kernel.org to help us keep track of
this -- thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
