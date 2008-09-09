From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some
 time
Date: Tue, 9 Sep 2008 20:16:24 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0809091947560.17070@netcore.fi>
References: <20080902150008.GD7289@schleppi.birkenwald.de> <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com> <20080909003852.GA20315@pest>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:38722 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788AbYIIRje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 13:39:34 -0400
In-Reply-To: <20080909003852.GA20315@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Sep 2008, Bernhard Schmidt wrote:
> Working (all-hosts):
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\25S\0\3\0\305\305H\212/\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, MSG_CONFIRM) = 64
>
> Non-working (RIPng group):
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305HCA\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305H\36F\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)

I wonder if it's relevant that msg_iov in working case has MSG_CONFIRM 
but in non-working case this is zero?  I guess not but apart from the 
contents of msg_iov, that's the only difference..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
