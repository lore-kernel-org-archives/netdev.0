From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 7 Jun 2005 01:01:01 -0700
Message-ID: <OFB68D40CB.B0CAE212-ON88257019.002B61C8-88257019.002C0A18@us.ibm.com>
References: <20050607.164749.62298775.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.164749.62298775.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 06/07/2005 
12:47:49 AM:


> No, kernel should send 5, if application use old API, of course.

> --yoshfuji

Ok, but this gets back to my point. If the program source
doesn't have #ifdefs like you suggested (for example, if
it was written before the new API existed), then it'll still
have an error, but that error won't show up until the next
time it's recompiled. So, an old binary will work fine, but
recompiling it will get EINVAL on the setsockopt() calls.
The old binary will work, the old source will compile, but
the new binary will not work, and may not be found until
much later.

The two API's are fundamentally incompatible, because
they have common names that do different things, and in
the first, the boolean socket option and cmsg_type must
be the same, in the second, they cannot be.

I think it's better to break and fix any use of these
right away instead of delaying the error until the next
time some old binary is recompiled and run, don't you?

                                                +-DLS
