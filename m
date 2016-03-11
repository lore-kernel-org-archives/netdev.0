From: Edward Cree <ecree@solarflare.com>
Subject: Re: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable
 outer Tx checksum by default)
Date: Fri, 11 Mar 2016 19:59:23 +0000
Message-ID: <56E3239B.7080009@solarflare.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
 <56E31A89.9020602@solarflare.com>
 <CALx6S37G5N-3GxXYf8uF9p8QNC+U_d6-Vf+8Jg6bFqEv_FpULg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:8052 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbcCKUMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 15:12:05 -0500
In-Reply-To: <CALx6S37G5N-3GxXYf8uF9p8QNC+U_d6-Vf+8Jg6bFqEv_FpULg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 19:57, Tom Herbert wrote:
> On Fri, Mar 11, 2016 at 11:20 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Tom,
>>
>> Are you planning to / working on implementing this?  If not, I might have a
>> crack at it; I've talked to our firmware guys and (provisionally) we think
>> we can support it in current sfc hardware.
>> Or were there any blocking problems raised in the thread?  My understanding
>> of the IP ID issue was that it only matters for the inner frame, because
>> the rest aren't TCP (so hopefully no-one is doing SLHC on them).  But I may
>> have missed something.
>>
> Right, then the interface would need to just include the offset of the
> IP ID. But doesn't this break using LCO with GSO though-- i.e. the
> outer checksum and inner checksum still need to be updated per packet
> so we need to tell device where outer checksum(s) is.
No, outer checksum shouldn't change: IP ID is protected by inner IP header
checksum, which device will edit.  No?

-Ed
