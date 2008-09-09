From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
 some time
Date: Tue, 09 Sep 2008 13:13:55 -0700 (PDT)
Message-ID: <20080909.131355.74431708.davem@davemloft.net>
References: <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com>
	<20080909003852.GA20315@pest>
	<alpine.LRH.1.10.0809091947560.17070@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: berni@birkenwald.de, dlstevens@us.ibm.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754250AbYIIUOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:14:02 -0400
In-Reply-To: <alpine.LRH.1.10.0809091947560.17070@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Tue, 9 Sep 2008 20:16:24 +0300 (EEST)

> On Tue, 9 Sep 2008, Bernhard Schmidt wrote:
> > Working (all-hosts):
> > sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\25S\0\3\0\305\305H\212/\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, MSG_CONFIRM) = 64
> >
> > Non-working (RIPng group):
> > sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305HCA\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)
> > sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305H\36F\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)
>
> I wonder if it's relevant that msg_iov in working case has
> MSG_CONFIRM but in non-working case this is zero?  I guess not but
> apart from the contents of msg_iov, that's the only difference..

MSG_CONFIRM refreshes the route's neighbour ->confirmed timestamp with
the current value of jiffies.

I really can't see how that could lead to the observed behavior, but who
knows at this point :)

