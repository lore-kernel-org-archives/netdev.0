From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: warnings in git-wireless
Date: Wed, 06 Jun 2007 15:33:46 -0700
Message-ID: <4667364A.4040803@linux.intel.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org>	<46671E5D.9070304@linux.intel.com> <20070606163534.6a6cffb7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070606163534.6a6cffb7.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 06 Jun 2007 13:51:41 -0700 James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> 
>>>>  * make C=2 CF=-Wall will complain if you use ARRAY_SIZE on global data
>>>>  */
>>>> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
>>> This is identical to ARRAY_SIZE.
>>>
>>> And if there's some problem with ARRAY_SIZE then fix ARRAY_SIZE!  Don't go 
>>> off and create some private thing and leave everyone else twisting in the
>>> wind.
>> The code was resolving the sparse warnings.  
> 
...
> Your GLOBAL_ARRAY_SIZE() is, afaict, identical to ARRAY_SIZE().

>From include/linux/kernel.h

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]) + __must_be_array(arr))

>From drivers/net/wireless/mac80211/iwlwifi/iwl-helpers.h

#define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

The '+ __must_be_array(arr)' part of ARRAY_SIZE was causing sparse to complain 
with:

drivers/net/wireless/mac80211/iwlwifi/base.c:4646:22: error: cannot size expression
...

When I had run my builds, I had restricted the sparse checks to just iwlwifi 
(vs. checking the rest of the kernel).

I just ran it C=2 CF=-Wall against the rest of the kernel and do see other code 
with the same problem, eg:

sound/core/memalloc.c:521:14: error: cannot size expression
...

I had erroneously thought it was just a problem with iwlwifi...

Thanks,
James
