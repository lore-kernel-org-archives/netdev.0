From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 7 Jun 2005 01:04:17 -0700
Message-ID: <OF012E620B.73A29076-ON88257019.002C1FE5-88257019.002C56ED@us.ibm.com>
References: <20050607.165536.75463878.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.165536.75463878.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 06/07/2005 
12:55:36 AM:

> In article <20050607.164749.62298775.yoshfuji@linux-ipv6.org> (at Tue, 
07 Jun 
> 2005 16:47:49 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 
<yoshfuji@linux-ipv6.org> says:

> > No, kernel should send 5, if application use old API, of course.

> This can be implemented like this (based on codes from our repository):

> /* RFC2292bis */
> if (np->rxopt.bits.rxhbh && opt->hop) {
> u8 *ptr = skb->nh.raw + opt->hop;
> put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
> }
> /* RFC2292 */
> if (np->rxopt.bits.rxhbh2292 && opt->hop) {
> u8 *ptr = skb->nh.raw + opt->hop;
> put_cmsg(msg, SOL_IPV6, IPV6_2292HOPOPTS, (ptr[1]+1)<<3, ptr);
> }

> --yoshfuji

Sure, it's easy to do. But the application that's using
it has broken source, and nobody will know until after it's
recompiled.

I'd just have a single flag for all, on the assumption that
they're either using old API exclusively, or new. But, again,
it leaves a land mine for the source bug in the application
that you're allowing to still work.

                                                +-DLS
