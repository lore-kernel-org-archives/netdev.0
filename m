From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 09:26:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.092642.47232575.yoshfuji@linux-ipv6.org>
References: <20031127221928.F25015@flint.arm.linux.org.uk>
	<1069974209.5349.7.camel@teapot.felipe-alfaro.com>
	<20031128.092326.39861126.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, davem@redhat.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <20031128.092326.39861126.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031128.092326.39861126.yoshfuji@linux-ipv6.org> (at Fri, 28 Nov 2003 09:23:26 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

>  2)   memset(dst, 0, len);
>       strncpy(dst, src, len);

oops, this should be

        memset(dst, 0, len);
        if (len > 0)
          strncpy(dst, src, len - 1);


>  3)   if (len)
>          strncpy(dst, src, len - 1);
>       dst[len] = 0;
> 
> (or, say, strncpy0()).

Note: in this case, we need to fix strncpy() first 
to zero-out rest of destination buffer.

--yoshfuji
