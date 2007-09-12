From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on creation.
Date: Wed, 12 Sep 2007 08:48:07 -0600
Message-ID: <m1odg89byw.fsf@ebiederm.dsl.xmission.com>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
	<46E7F466.1060704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51128 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965147AbXILOsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:48:43 -0400
In-Reply-To: <46E7F466.1060704@openvz.org> (Pavel Emelyanov's message of "Wed,
	12 Sep 2007 18:15:02 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

>> +	}
>>  
>> -		tbp = peer_tb;
>> -	} else
>> -		tbp = tb;
>
> The intention of this part was to get the same parameters for
> peer as for the first device if no "peer" argument was specified
> for ip utility. Does it still work?

I know it is problematic because we try to assign the same name
to both network devices, if we assign a name to the primary
network device.  That can't work.

Beyond that I had some really weird crashes while testing this
piece of code, especially when I did not specify a peer parameter.

So it was just easier to avoid the problem with this patch then
to completely root cause it.

I think the easiest semantic is to not have any peer parameters
if they were not specified, then to try and to figure out which
subset of parameters to copy.  If I hadn't been getting weird
kernel crashes I would not have cared.

Eric
