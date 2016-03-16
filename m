From: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to
 4KB regardless of system page size"
Date: Wed, 16 Mar 2016 16:49:00 +1100
Message-ID: <56E8F3CC.3070203@ozlabs.ru>
References: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
 <CAJ3xEMhxUuQj+E00fa-tEKz+dVzDqFspC80Z=k7UPZpOP30H3g@mail.gmail.com>
 <56E8BFFE.9000803@ozlabs.ru> <20160316051021.GC66645@x-vnc01.mtx.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Huy Nguyen <huyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Carol L Soto <clsoto-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Brian J King <bjking1-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160316051021.GC66645-lgQlq6cFzJSjLWYaRI30zHI+JuX82XLG@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/16/2016 04:10 PM, Eli Cohen wrote:
> On Wed, Mar 16, 2016 at 01:07:58PM +1100, Alexey Kardashevskiy wrote:
>>
>> So with v4.5 as a host, there is no actual distro available today to
>> use as a guest in the next 6 months (or whatever it takes to
>> backport this partucular patch back there).
>>
>> You could have added a module parameter to enforce the old behavoir,
>> at least...
>>
>> And sorry but from the original commit log I could not understand
>> why exactly all existing guests need to be broken. Could you please
>> point me to a piece of documentation describing all this UAR
>> bisuness (what is UAR, why 128 UARs are required and for what, etc).
>> Thanks.
>>
>
> We are going to send a patch that fixes this using a module parameter.
> The patch will be on top of Huy's patch.
>
> Some background to the problem: mlx4 supported devices require 128 UAR

What does UAR stand for?

> pages from PCI memory space defined by BAR2-3. Each UAR page can be
> any power of 2 value from 4K up to 64K. Before Huy's patch the driver
> chose UAR page size to be equal to system page size. Since PowerPC's
> page size is 64K this means minimum requirement of UAR pages is not
> met (default UAR BAR is 8MB and only half of it is really reserved for
> UARs).

And what was the downside? afaict the performance was good...


> More details can be found in the programmer's manual.

Can you please point me to this manual on the website? I tried, honestly, 
could not find it. Thanks.


-- 
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
