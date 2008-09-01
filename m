From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Mon, 1 Sep 2008 20:03:42 +0200
Message-ID: <20080901180342.GA13248@pest>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest> <alpine.LRH.1.10.0809012055460.6006@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:36643 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbYIASDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 14:03:47 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.1.10.0809012055460.6006@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 01, 2008 at 08:57:51PM +0300, Pekka Savola wrote:

Hello Pekka,

> On Mon, 1 Sep 2008, Bernhard Schmidt wrote:
>> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58),  
>> inet_pton(AF_INET6, "ff02::2", &sin6_addr), sin6_flowinfo=0,  
>> sin6_scope_id=0},  
>> msg_iov(1)=[{"\200\0\0\0004x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 
>> 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, 
>> ...},  
>> msg_flags=MSG_PEEK|MSG_PROXY|MSG_WAITALL|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 
>> 0) = 64
>
> versus:
>
>> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58),  
>> inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0,  
>> sin6_scope_id=0},  
>> msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H\354\212\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 
>> 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, 
>> ...}, msg_flags=MSG_CTRUNC}, 0) = -1 EINVAL (Invalid argument)
>
> It seems that in the latter case, you haven't specified the interface  
> (sin6_scope_id=0), but in the former case you have.  You can't send to  
> link-local multicast groups if you have multiple interface if the  
> interface isn't specified.

I did specify the interface:

miredo:~# ping6 -I eth0 ff02::2
PING ff02::2(ff02::2) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.034 ms
[...]
miredo:~# ping6 -I eth0 ff02::9
PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
ping: sendmsg: Invalid argument
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.033 ms

I have no idea what the different flags mean or where they come from.

Also please note that broken ping6 is just a symptom, the real problem
is ripngd suddenly not being able to send to the multicast group
anymore.

Bernhard
