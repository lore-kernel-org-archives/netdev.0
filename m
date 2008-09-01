From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some
 time
Date: Mon, 1 Sep 2008 20:57:51 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0809012055460.6006@netcore.fi>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:53971 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbYIAR6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2008 13:58:31 -0400
In-Reply-To: <20080901170101.GA12236@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Sep 2008, Bernhard Schmidt wrote:
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), 
> inet_pton(AF_INET6, "ff02::2", &sin6_addr), sin6_flowinfo=0, 
> sin6_scope_id=0}, 
> msg_iov(1)=[{"\200\0\0\0004x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 
> 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, 
> cmsg_type=, ...}, 
> msg_flags=MSG_PEEK|MSG_PROXY|MSG_WAITALL|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 
> 0) = 64

versus:

> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), 
> inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, 
> sin6_scope_id=0}, 
> msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H\354\212\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 
> 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, 
> cmsg_type=, ...}, msg_flags=MSG_CTRUNC}, 0) = -1 EINVAL (Invalid 
> argument)

It seems that in the latter case, you haven't specified the interface 
(sin6_scope_id=0), but in the former case you have.  You can't send to 
link-local multicast groups if you have multiple interface if the 
interface isn't specified.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
