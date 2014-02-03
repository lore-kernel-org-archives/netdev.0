From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers: staging: lustre: lustre: include: add "__attribute__((packed))"
 for the related union
Date: Mon, 03 Feb 2014 19:35:24 +0800
Message-ID: <52EF7EFC.5040704@gmail.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com> <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda> <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda> <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com> <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com> <20140203085855.GA26722@mwanda> <52EF6965.6040406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jacques-charles.lafoucriere-KCE40YydGKI@public.gmane.org, jinshan.xiong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52EF6965.6040406-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/03/2014 06:03 PM, Chen Gang wrote:
> On 02/03/2014 04:58 PM, Dan Carpenter wrote:
>> On Sat, Feb 01, 2014 at 09:57:39PM +0800, Chen Gang wrote:
>>> It seems, our kernel still stick to treate 'pack' region have effect
>>> with both 'align' and 'sizeof'.
>>>
>>
>> It's not about packed regions.  It's about unions.  It's saying the
>> sizeof() a union is a multiple of 4 unless it's packed.
>>
>> union foo {
>> 	short x;
>> 	short y;
>> };
>>
>> The author intended the sizeof(union foo) to be 2 but on metag arch then
>> it is 4.
>>
> 
> Yeah, just like your original discussion.  :-)
> 
> 
> Hmm... can we say: "for metag compiler, in a pack region, it considers
> variables alignment, but does not consider about struct/union alignment
> (except append packed to each related struct/union)".
> 
> For compatible (consider about its ABI), it has to keep this features,
> but for kernel, it needs be changed.
> 
> So, I suggest to add one parameter to compiler to switch this feature,
> and append this parameter to KBUILD_CFLAGS in "arch/metag/Makefile"
> which can satisfy both ABI and kernel.
> 

After append the parameter to KBUILD_CFLAGS in "arch/metag/Makefile",

 - I guess/assume "include/uapi/*" should/will not need be modified.

 - but need check all files in "arch/metag/include/uapi/*".
   (add padding data for packed struct/union when __KERNEL__ defined)

 - maybe we have to process metag related ABI which not in "*/uapi/*"
   (add padding data for packed struct/union when __KERNEL__ defined)
   and when we find them, recommend to move all of them to "*/uapi/*".


Sorry, I don't know whether this way is the best way or not, but for me
it is an executable way to solve this feature issue and satisfy both
kernel and ABI.


Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
--
To unsubscribe from this list: send the line "unsubscribe linux-metag" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
