From: "Srivatsa S. Bhat" <srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: CIFS mount: 3.2.0-rc3 suspend crash
Date: Mon, 05 Dec 2011 23:39:20 +0530
Message-ID: <4EDD08D0.9030401@linux.vnet.ibm.com>
References: <4ED56C12.1040708@gmail.com> <4ED5C047.6040500@linux.vnet.ibm.com> <20111130062502.68d9db59@tlielax.poochiereds.net> <4ED81077.2080305@gmail.com> <4ED8C940.20509@linux.vnet.ibm.com> <20111205174126.GF627@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Woody Suwalski <terraluna977-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux PM mailing list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Belisko Marek <marek.belisko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111205174126.GF627-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/05/2011 11:11 PM, Tejun Heo wrote:

> Hello, Srivatsa.
> 
> On Fri, Dec 02, 2011 at 06:19:04PM +0530, Srivatsa S. Bhat wrote:
>> So how about solving this problem more fundamentally, such as defining a
>> freezable wrapper over kernel_recvmsg like:
>>
>> #define kernel_recvmsg_freezable(sock, msg, vec, num, size, flags)      \
>> ({                                                                      \
>>         kernel_recvmsg(sock, msg, vec, num, size, flags)                \
>> 	try_to_freeze();                                                \
>> })
>>
>> and using it instead of kernel_recvmsg(), throughout the kernel?
>>
>> But kernel_recvmsg is an exported symbol. So if we are very very unwilling
>> to change the kernel ABI, we could probably think about adding try_to_freeze()
>> inside kernel_recvmsg itself,like this (but see below about my thoughts about
>> which one is better):
> 
> I don't necessarily object to introducing the wrapper but I don't
> really think we should be doing s//g over the source tree without
> understanding where it's actually necessary.  For kernel threads and
> user threads out of the signal delivery path, try_to_freeze() is an
> exceptional event which introduces behavior which can be difficult to
> reproduce track down and spreading it without actually knowing what
> the surrounding code is doing doesn't sound like a good idea to me.
> 


Yeah, I agree. But I remember seeing almost _exactly_ the same code
as CIFS loop in some other place. I'll see if I can track it down and
also understand if it might cause problems. If I find it to be worth it
to use the same solution as above, I'll try adding the wrapper and using
it there. Else, better to keep it as it is, as you mentioned. Thank you.

Regards,
Srivatsa S. Bhat
