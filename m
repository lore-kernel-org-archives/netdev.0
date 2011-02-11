From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/4] net: extend netlink interface to handle
 generic slave management
Date: Fri, 11 Feb 2011 18:40:43 +0100
Message-ID: <20110211174042.GA2578@psychotron.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
 <4D555A43.5000005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, fubar@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757918Ab1BKS12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 13:27:28 -0500
Content-Disposition: inline
In-Reply-To: <4D555A43.5000005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 11, 2011 at 04:48:19PM CET, kaber@trash.net wrote:
>On 11.02.2011 16:21, Jiri Pirko wrote:
>> Drivers like bridge and bonding uses their own way to manipulate with
>> underlink devices. This is an attempt to introduce common interface using
>> netlink.
>
>Thanks for working on this, this has been on my TODO list for a
>long time.
>
>> --- a/include/linux/if_link.h
>> +++ b/include/linux/if_link.h
>> @@ -136,6 +136,9 @@ enum {
>>  	IFLA_PORT_SELF,
>>  	IFLA_AF_SPEC,
>>  	IFLA_GROUP,		/* Group the device belongs to */
>> +	IFLA_SLAVE_LIST,
>> +	IFLA_SLAVE_ADD,
>> +	IFLA_SLAVE_DEL,
>
>I don't like this very much though, the attributes usually contain
>data, not commands. We already have NEWLINK, DELLINK etc. on the
>top level, the combinations of NEWLINK/NLM_F_CREAT and SLAVE_DEL
>or DELLINK and SLAVE_ADD and so on simply don't make sense.
>
>We usually also try to keep the interface symetrical in both
>directions (a NEWLINK message from the kernel is identical to a
>NEWLINK message from userspace, a DELLINK message as well besides
>containing additional information), so using different attributes
>for dumping slaves than for adding them seems wrong. If we can
>dump all slaves in one message, it should also be possible to
>enslave multiple devices using the same message.
>
>What I originally had planned to support enslaving devices is to
>make use of the IFLA_MASTER attribute. The IFLA_MASTER attribute
>would contain the bond or bridge ifindex and the IFLA_IFNAME
>attribute or ifindex would specify the slave device. All operations
>would be performed on the slave device as usual, if the IFLA_MASTER
>attribute is present we'd additionally call a master specific
>callback for enslaving or releasing slave devices. Besides allowing
>to keep messages symetrical, an additional benefit is that it would
>be possible to create and enslave a device in a single step.
>

Yes, that makes sense. I'm going to respin the patchset soon.

Jirka
>
