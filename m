From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 16:55:36 +0900 (JST)
Message-ID: <20050607.165536.75463878.yoshfuji@linux-ipv6.org>
References: <20050607.160521.73986501.yoshfuji@linux-ipv6.org>
	<OF2D6866A4.ACD65B11-ON88257019.0027E8B0-88257019.002A2862@us.ibm.com>
	<20050607.164749.62298775.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <20050607.164749.62298775.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050607.164749.62298775.yoshfuji@linux-ipv6.org> (at Tue, 07 Jun 2005 16:47:49 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> No, kernel should send 5, if application use old API, of course.

This can be implemented like this (based on codes from our repository):

       /* RFC2292bis */
       if (np->rxopt.bits.rxhbh && opt->hop) {
               u8 *ptr = skb->nh.raw + opt->hop;
               put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
       }
       /* RFC2292 */
       if (np->rxopt.bits.rxhbh2292 && opt->hop) {
               u8 *ptr = skb->nh.raw + opt->hop;
               put_cmsg(msg, SOL_IPV6, IPV6_2292HOPOPTS, (ptr[1]+1)<<3, ptr);
       }

--yoshfuji
