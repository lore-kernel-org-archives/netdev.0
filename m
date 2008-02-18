From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 22:17:27 +0100
Message-ID: <47B9F5E7.3020905@trash.net>
References: <20080215.025855.202184003.davem@davemloft.net>	<1203097370.21308.18.camel@localhost>	<47B9A20C.10304@trash.net> <20080218.125525.192686382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080218.125525.192686382.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Date: Mon, 18 Feb 2008 16:19:40 +0100
>
>   
>> Joe Perches wrote:
>>     
>>>
>>>> We specifically removed this sort of thing, please don't
>>>> add it back.
>>>>         
>> Why?
>>     
>
> We converted the entire tree over the print_mac(), and since
> the MAC_FMT stuff was therefore no longer used we could
> remove it.
>
> Some references slipped back in somehow, and thus MAC_FMT
> did too.
>
> There is no reason to keep around a global interface for
> _one_ user when that user can use the recommended interface
> just as equally as the rest of the tree which we converted.
>
> This is a pr_debug() statement we're talking about here.
> :-)
>   

The way pr_debug is implemented it still results in two function
calls per packet since the compiler doesn't know that it doesn't
have visible side-effects besides modifying the (unused) buffer.
I confirmed this using codiff.
