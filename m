From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Refine IPv6 Address Validation Timer
Date: Fri, 27 Sep 2002 19:30:14 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271530.TAA21206@sex.inr.ac.ru>
References: <20020928.001617.91124319.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.001617.91124319.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 28, 2 00:16:17 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> So, is this reasonable?

Yes, I like this.

Let's only delete this:

> +	if (time_before(now + HZ/2, jiffies)) {
> +		ADBG((KERN_WARNING 
> +		      "addrconf_verify(): too slow; jiffies - now = %ld\n",
> +		      (long)jiffies - (long)now));
> +	}

I do not understand how this survived. If you worry about infinite
spinning in loop you could make this check real, f.e. breaking loop
when jiffies >= now+2. In this form it is just mud.

Alexey
