From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 09:23:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.092326.39861126.yoshfuji@linux-ipv6.org>
References: <1069970770.2138.10.camel@teapot.felipe-alfaro.com>
	<20031127221928.F25015@flint.arm.linux.org.uk>
	<1069974209.5349.7.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, davem@redhat.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <1069974209.5349.7.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1069974209.5349.7.camel@teapot.felipe-alfaro.com> (at Fri, 28 Nov 2003 00:03:29 +0100), Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> says:

> So, as I see:
> 
> 1. We should fix strncpy()
> 2. I should replace strlcpy() with strncpy() in my patches.

I think it is NOT correct. 
It SEEMS unsafe to use strncpy() even if it terminated 
string correctly.

So, I'd suggest to replace

    strlcpy(dst, src, len);

with 

 1)   strlcpy0(dst, src, len);

where strlcpy0() is provided in my previous mail,
or with

 2)   memset(dst, 0, len);
      strncpy(dst, src, len);

(or say, strncpy0())
or, with

 3)   if (len)
         strncpy(dst, src, len - 1);
      dst[len] = 0;

(or, say, strncpy0()).

--yoshfuji
