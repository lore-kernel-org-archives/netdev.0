From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next PATCH 1/5] net: Add netdev Rx page allocation function
Date: Mon, 10 Nov 2014 18:02:27 -0800
Message-ID: <54616E33.1030207@redhat.com>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>	<20141110195158.16182.71937.stgit@ahduyck-vm-fedora20> <CAHA+R7PigH6ZZBP0DzAPwLMwsK85aadj4hH3iahhOH2ehfYJvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHA+R7PigH6ZZBP0DzAPwLMwsK85aadj4hH3iahhOH2ehfYJvg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 11/10/2014 04:26 PM, Cong Wang wrote:
> On Mon, Nov 10, 2014 at 11:51 AM, Alexander Duyck
> <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> This patch implements __netdev_alloc_pages and __netdev_alloc_page.  These
>> are meant to replace the __skb_alloc_pages and __skb_alloc_page functions.
>> The reason for doing this is that it occurred to me that __skb_alloc_page is
>> supposed to be passed an sk_buff pointer, but it is NULL in all cases where
>> it is used.  Worse is that in the case of ixgbe it is passed NULL via the
>> sk_buff pointer in the rx_buffer info structure which means the compiler is
>> not correctly stripping it out.
> These netdev_*() have nothing related with struct net_device, please
> find a better prefix. Also, they are in skbuff.h, you perhaps want to move them
> to netdevice.h.

The netdev_ prefix is really meant indicate where they are supposed to 
be used, not so much the arguments being passed, and the fact that 
historically this is what we had back in the kernel a couple years ago.  
I suppose I could rename them to __dev_alloc_page(s) and 
dev_alloc_page(s) since that seems to be the precedent for how this is 
handled for skb's.  I'll submit something tomorrow if there aren't any 
other name requests.

I would prefer to keep them in skbuff.h since this is buffer allocation 
that will later be handed off via either build_skb or skb_add_rx_frag to 
an sk_buff.

Thanks,

Alex


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
