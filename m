From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [patch iproute2] iplink: add support for bonding netlink
Date: Tue, 29 Oct 2013 16:12:32 -0400
Message-ID: <527016B0.5060600@redhat.com>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us> <1382111401-1233-1-git-send-email-jiri@resnulli.us> <loom.20131029T194706-188@post.gmane.org>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Scott Feldman <sfeldma@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab3J2UMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 16:12:35 -0400
In-Reply-To: <loom.20131029T194706-188@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2013 03:00 PM, Scott Feldman wrote:
> Jiri Pirko <jiri <at> resnulli.us> writes:
>
>> +		} else if (matches(*argv, "active_slave") == 0) {
>> +			NEXT_ARG();
>> +			ifindex = if_nametoindex(*argv);
>> +			if (!ifindex)
>> +				return -1;
>> +			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, ifindex);
>> +		} else if (matches(*argv, "clear_active_slave") == 0) {
>> +			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, 0);
>
> How do active_slave and clear_active_slave work from the ip link cmd line
> when bond is added, but doesn't have any slaves yet?  I did:
>
>    ip link add bond1 type bond mode 1
>    ip link set dev eth1 master bond1
>    ip link set dev eth2 master bond1
>
> Then tried:
>
>    ip link add bond1 type bond active_slave eth1
>    RTNETLINK answers: File exists
>
> Or:
>
>    ip link set dev bond1 active_slave eth1
>    Error: either "dev" is duplicate, or "active_slave" is a garbage.

You need to do:
	ip link set dev bond1 type bond active_slave eth1

'active_slave' argument is only defined for the 'type bond' operations.

You can not set active slave before enslaving the device and this
series doesn't change that.

-vlad

>
> I must be dense but I can't figure how you can set active_slave before
> slaves have been added to bond, or even after slaves have been added
> to bond.
>
>> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
>> index 8b68c78..1825dc5 100644
>> --- a/man/man8/ip-link.8.in
>> +++ b/man/man8/ip-link.8.in
>>   <at>  <at>  -51,6 +51,7  <at>  <at>  ip-link \- network device configuration
>>   .ti -8
>>   .IR TYPE " := [ "
>>   .BR bridge " | "
>> +.BR bond " ]"
>
> That should be " | "?
>
> With patch applied, the man page shows:
>
>         TYPE := [ bridge | bond ] can | dummy | ifb | ipoib | macvlan | ...
>
> -scott
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
