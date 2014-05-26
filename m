From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] bring netlink interface to par with brctl
 show macs
Date: Mon, 26 May 2014 07:05:01 -0400
Message-ID: <53831FDD.4020902@mojatatu.com>
References: <1401023755-8174-1-git-send-email-jhs@emojatatu.com> <1401071747.17377.111.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, vyasevic@redhat.com,
	john.r.fastabend@intel.com, sfeldma@cumulusnetworks.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37290 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaEZLFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 07:05:05 -0400
Received: by mail-ig0-f174.google.com with SMTP id h3so2974129igd.13
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 04:05:04 -0700 (PDT)
In-Reply-To: <1401071747.17377.111.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/14 22:35, Ben Hutchings wrote:
> On Sun, 2014-05-25 at 09:15 -0400, Jamal Hadi Salim wrote:

>> +		if (dev == NULL) {
>> +			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
>
> You left another debug message here.
>
>> +			return -ENODEV;
>>   		}

>> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
>> +				dev->name);
>
> And here.

Those two just adhere to the coding style used in the rest of the fdb
code. I could remove them and send subsequent patches to remove
equivalent debugs in the rest of the code. To me they seem useful
although i have seen very strong views against them in the past.

>> +			return -EINVAL;
>> +		}
> [...]
>
> Why does this only call the device's own ndo_fdb_dump and not a
> bridge-port's bridge's ndo_fdb_dump or ndo_dflt_fdb_dump?

The target is a specific bridge not a bridge port. Having
said that, it is (probably) possible there are physical or virtual
bridge ports whose master is the targeted bridge that are sheltering
fdb entries we want to dump that are not in the bridge's fdb.
Macvlans or vmdq maybe? What did you have in mind?

cheers,
jamal



> Ben.
>
