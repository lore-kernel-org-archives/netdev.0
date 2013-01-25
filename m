From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 19:08:27 +0100
Message-ID: <20130125180827.GA1821@minipsycho.orion>
References: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
 <13906.1359077701@death.nxdomain>
 <20130125063713.GA1659@minipsycho.orion>
 <20130125072221.GB1659@minipsycho.orion>
 <21365.1359136387@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:57897 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3AYSIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 13:08:31 -0500
Received: by mail-ea0-f175.google.com with SMTP id d1so277109eab.6
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 10:08:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <21365.1359136387@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 25, 2013 at 06:53:07PM CET, fubar@us.ibm.com wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>>Fri, Jan 25, 2013 at 07:37:13AM CET, jiri@resnulli.us wrote:
>>>Fri, Jan 25, 2013 at 02:35:01AM CET, fubar@us.ibm.com wrote:
>>>>Jiri Pirko <jiri@resnulli.us> wrote:
>>>>
>>>>>Makes more sense to have randomly generated address by default than to
>>>>>have all zeroes. It also allows user to for example put the bond into
>>>>>bridge without need to have any slaves in it.
>>>>>
>>>>>Also note that this changes only behaviour of bonds with no slaves. Once
>>>>>the first slave device is enslaved, its address will be used (no change
>>>>>here).
>>
>>
>>Also, this is not entirely true now. Example:
>>
>>eth1 has 52:54:00:b8:30:0b
>>
>># ip link add bondx address 22:33:44:55:66:77 type bond
>># ip link set eth1 master bondx
>>
>>Now both bondx and eth1 has 22:33:44:55:66:77
>>
>>Shouldn't both have 52:54:00:b8:30:0b ?
>
>	This is the way bonding has worked for as long as I can recall.
>The MAC of the first slave is assigned to the master, unless the bond
>has had its MAC manually set to something prior to the first slave being
>added.  If the bond's MAC has been set manually, then that MAC is used
>instead of the first slave's MAC.
>
>	Your patch doesn't appear to change that behavior, but it does
>substitute a random MAC in place of the all zeroes MAC used previously
>(and tests a flag to determine if the MAC has been manually set instead
>of checking for the all zeroes MAC).

Yeah, I know my patch is not changing this. I was just making sure it is
correct.

>
>	I know of customers that rely on this behavior to explicitly set
>the MAC of the bond (for filtering or accounting purposes).  It probably
>should be documented more clearly, but I don't think it should be
>changed.
>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
