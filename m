From: Philip Craig <philipc@snapgear.com>
Subject: Re: [net-next PATCH 16/16] Add documentation
Date: Wed, 08 Oct 2008 10:32:22 +1000
Message-ID: <48EBFF96.8020305@snapgear.com>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.5367.stgit@este> <alpine.LNX.1.10.0810030949300.3893@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:43898 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753831AbYJHAcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:32:25 -0400
In-Reply-To: <alpine.LNX.1.10.0810030949300.3893@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
>> +2. Redirecting traffic
>> +======================
>> +
>> +Transparent proxying often involves "intercepting" traffic on a router. This is
>> +usually done with the iptables REDIRECT target, however, there are serious
>> +limitations of that method. One of the major issues is that it actually
>> +modifies the packets to change the destination address -- which might not be
>> +acceptable in certain situations. (Think of proxying UDP for example: you won't
>> +be able to find out the original destination address. Even in case of TCP
>> +getting the original destination address is racy.)
> 
> IIRC, you _can_ find out, though I agree it's rather a hack (with 
> tproxy, you can just use the address as received via recvmsg):
> 
> 	getsockopt(fd, SOL_IP, SO_ORIGINAL_DST, &sockaddr, &sizeptr);

Yes, but the problem is that SO_ORIGINAL_DST is only implemented for TCP.
And I guess that the race for TCP is that the conntrack may not exist when you
call getsockopt() (not sure that is something you'll hit in practice though).

