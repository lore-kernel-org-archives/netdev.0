From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 11:12:23 +0200
Message-ID: <4C8F3C77.7010302@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>	<1284410883.13351.14.camel@localhost.localdomain> <20100913.201730.27805132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, arnd@arndb.de, mst@redhat.com,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100913.201730.27805132.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  On 09/14/2010 05:17 AM, David Miller wrote:
> From: Shirley Ma<mashirle@us.ibm.com>
> Date: Mon, 13 Sep 2010 13:48:03 -0700
>
>> +		base = (unsigned long)from->iov_base + offset1;
>> +		size = ((base&  ~PAGE_MASK) + len + ~PAGE_MASK)>>  PAGE_SHIFT;
>> +		num_pages = get_user_pages_fast(base, size, 0,&page[i]);
>> +		if ((num_pages != size) ||
>> +		    (num_pages>  MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
>> +			/* put_page is in skb free */
>> +			return -EFAULT;
> What keeps the user from writing to these pages in it's address space
> after the write call returns?
>
> A write() return of success means:
>
> 	"I wrote what you gave to me"
>
> not
>
> 	"I wrote what you gave to me, oh and BTW don't touch these
>           pages for a while."
>
> In fact "a while" isn't even defined in any way, as there is no way
> for the write() invoker to know when the networking card is done with
> those pages.

That's what io_submit() is for.  Then io_getevents() tells you what "a 
while" actually was.

-- 
error compiling committee.c: too many arguments to function

