From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Thu, 16 Dec 2010 12:18:05 -0800 (PST)
Message-ID: <20101216.121805.59690737.davem@davemloft.net>
References: <616589.97517.qm@web29017.mail.ird.yahoo.com>
	<4CF75BC3.1020606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: albertpretorius@yahoo.co.uk, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, jmorris@namei.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103Ab0LPURh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 15:17:37 -0500
In-Reply-To: <4CF75BC3.1020606@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 02 Dec 2010 16:41:39 +0800

> Albert Pretorius wrote, at 12/02/2010 03:45 PM:
>> Hi
>> 
>> --- On Wed, 1/12/10, Shan Wei <shanwei@cn.fujitsu.com> wrote:
>>> I think it make nonsense to translate data between loopback
>>> device and other e.g. eth0 device in same machine.
>> 
>> I agree, RFC4291 makes it clear for IPV6 that no interface should accept traffic from loopback, I should not have tried to make it behave like IPV4.
>> I can not find an equivalent statement for IPV4 though, all I could find is this from RFC3330:
>> 
>>    127.0.0.0/8 - This block is assigned for use as the Internet host
>>    loopback address.  A datagram sent by a higher level protocol to an
>>    address anywhere within this block should loop back inside the host.
>>    This is ordinarily implemented using only 127.0.0.1/32 for loopback,
>>    but no addresses within this block should ever appear on any network
>>    anywhere [RFC1700, page 5].
>> 
>> Do you perhaps know?
> 
> There are no same statement for IPv4 loopback address. I have checked RFC1122, RFC1700 and RFC5753 .		

Shan, you really need to handle this in the ipv6 routing code.

Your approach will only modify socket based route handling, it will
not handle the ipv6 forwarding case which as per the quoted RFC
sections must be handled too.
