From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 07:50:27 -0800
Message-ID: <m1wsb2k5vg.fsf@fess.ebiederm.org>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>
	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>
	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>
	<m1bpsellmv.fsf@fess.ebiederm.org> <49B14234.5030206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52890 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbZCFPud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:50:33 -0500
In-Reply-To: <49B14234.5030206@trash.net> (Patrick McHardy's message of "Fri\, 06 Mar 2009 16\:33\:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>>
>>>> Hmm.  Actually that appears to be a macvlan bug.  It looks like if I
>>>> change the macaddress on a macvlan we don't update the hash chains.
>>>> So unless we have the same low byte we will be on the wrong hash chain
>>>> and not receive the packets for the mac we specified.  Ouch!
>>> The address can only be changed while the device is down and unhashed.
>>
>> Point.  The dev_unicast/dev_unicast_delete in macvlan_set_mac_address
>> appears to be completely unnecessary then.
>
> I think thats correct.

Actually it is really weird.  We can change the mac address while
the devices is running but the code is broken because it does
not update the hash table.

> Refusing duplicate MACs (on one underlying device) makes sense, the
> results are undefined currently.

Then I will do that just for consistency.

> About the filtering - I don't like
> the idea too much given that we already have multiple possiblities
> to do that.

Agreed, and even more I can think of some reasons why would not want
that.  The observation I have is that if really want separation you
need separate vlans to the switch.  As the similar hardware based
features also don't perform egress filtering.

Eric

