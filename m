From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 08 Dec 2015 21:17:51 -0800
Message-ID: <5667B97F.2080407@cumulusnetworks.com>
References: <20151208.214411.2137019448940208712.davem@davemloft.net> <56679B2F.5080700@cumulusnetworks.com> <56679E4F.3020908@cumulusnetworks.com> <20151208.224100.1951416968376650648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	shm@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36773 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbbLIFRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 00:17:53 -0500
Received: by pfdd184 with SMTP id d184so23895823pfd.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 21:17:53 -0800 (PST)
In-Reply-To: <20151208.224100.1951416968376650648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/8/15, 7:41 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 8 Dec 2015 20:21:51 -0700
>
>> On 12/8/15 8:08 PM, David Ahern wrote:
>>> root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red
>>>
>>> root@kenny-jessie2:~# ip ru ls
>>> 0:    from all lookup local
>>> 32759:    from all oif vrf-red lookup vrf-red
>>> 32760:    from all iif vrf-green lookup vrf-green
>>> 32761:    from all oif vrf-green lookup vrf-green
>>> 32762:    from all iif vrf-blue lookup vrf-blue
>>> 32763:    from all oif vrf-blue lookup vrf-blue
>>> 32764:    from all iif vrf-red lookup vrf-red
>>> 32765:    from all oif vrf-red lookup vrf-red
>>> 32766:    from all lookup main
>>> 32767:    from all lookup default
>> d'oh. They don't fail in the sense of a user getting an error message
>> but they add duplicate entries. So, if I fix the duplicity (ie., don't
>> add a second one) would the patch be acceptable?
> No, people need to issue all the commands in order for the configuration
> to work in all kernels.
>
agreed. In which case, maybe the rules should not be added by default, but added only under a special vrf dev creation attribute or flag
(something like IFLA_VRF_AUTOCREATE_RULES  ?)
