From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 05:47:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.054724.116712136.yoshfuji@linux-ipv6.org>
References: <20031127194602.A25015@flint.arm.linux.org.uk>
	<20031128.045413.133305490.yoshfuji@linux-ipv6.org>
	<20031127200041.B25015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipe_alfaro@linuxmail.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk+lkml@arm.linux.org.uk
In-Reply-To: <20031127200041.B25015@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031127200041.B25015@flint.arm.linux.org.uk> (at Thu, 27 Nov 2003 20:00:41 +0000), Russell King <rmk+lkml@arm.linux.org.uk> says:

> The thing that worries me is that an incorrect strlcpy() conversion
> gives the impression that someone has thought about buffer underruns
> as well as overruns, and, unless someone /has/ actually thought about
> it, there could well still be a security problem lurking there.

Hmm, what do you actually mean by "buffer underruns?"

(If I'm correct) do you suggest that we should zero-out rest of 
destination buffer?

if so, we may want to have a function, say strlcpy0(), like this:

size_t strlcpy0(char *dst, const char *src, size_t maxlen)
{
  size_t len = strlcpy(dst, src, maxlen);
  if (maxlen && len < maxlen - 1)
    memset(dst + len + 1, 0, maxlen - len - 1);
  return len;
}

--yoshfuji
