From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 18:36:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF28610.3000004@pobox.com>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com> <3DF27EE7.4010508@pobox.com> <3DF2844C.F9216283@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3DF2844C.F9216283@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> It needs padding _only_ on SMP.  ____cacheline_aligned_in_smp.
[...]
> So your patch will do what you want it to do.  You should just tag the
> first member of a group with ____cacheline_aligned_in_smp, and keep an
> eye on things with offsetof().


thanks.

For this case, though, I want to align on cacheline bounaries even on 
UP, right?  That's why I picked ____cacheline_aligned.  It uses 
L1_CACHE_BYTES when !CONFIG_SMP.  Other uses of ____cacheline_aligned in 
the kernel seem to relate to irq matters, just like my groupings in tg3.h.

[obviously benchmarking can answer some of this, but I want to hammer 
out silliness first]

	Jeff
