From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Tue, 31 Dec 2013 07:54:34 -0800
Message-ID: <52C2E8BA.6000800@candelatech.com>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>  <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>  <1388429761.4410.1.camel@jlt4.sipsolutions.net>  <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>  <1388438724.4573.2.camel@jlt4.sipsolutions.net>  <20131230215701.GA4938@khazad-dum.debian.net>  <1388445188.18164.0.camel@jlt4.sipsolutions.net> <1388445422.26796.38.camel@joe-AO722> <alpine.DEB.2.02.1312310726540.1930@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1312310726540.1930-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/30/2013 10:32 PM, Julia Lawall wrote:
>>>>> I'm just thinking of a programmer, e.g. changing a struct like this:
>>>>>
>>>>>   struct foo {
>>>>>     u8 addr[ETH_ALEN];
>>>>> -  u16 dummy;
>>>>>   };
>>
>> I don't know of a way to catch that.
>> Anyone else?
>
> Well, one could have a semantic patch that checks for that.  But the
> problem is that it is very slow, and it only covers the cases that I can
> transform automatically, which currently means no pointers, only explicit
> arrays.
>
> On the other hand, I am finding the structure definition, so I can easily
> update the structure definition with an appropriate comment.
>
> struct foo {
>      u8 addr[ETH_ALEN]; /* must be followed by two bytes in the structure */
>      u16 dummy;
> };
>
> Unfortunately it is kind of verbose.  Could there be an attribute?  That
> could even easily be checked.

Can you not just add a build-time macro to check that sizeof(foo) >= 8
for each of these struct foos?  Or, is it required that the dummy field
be there and be not used by anything else?

Thanks,
Ben

>
> julia
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
