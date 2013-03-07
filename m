From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] macvlan: Set IFF_UNICAST_FLT flag to prevent unnecessary
 promisc mode.
Date: Thu, 07 Mar 2013 15:43:43 -0500
Message-ID: <5138FBFF.9000108@redhat.com>
References: <1362687708-8685-1-git-send-email-vyasevic@redhat.com> <5138F82F.6010005@candelatech.com> <5138F95A.9010305@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200Ab3CGUnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 15:43:45 -0500
In-Reply-To: <5138F95A.9010305@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2013 03:32 PM, Vlad Yasevich wrote:
> On 03/07/2013 03:27 PM, Ben Greear wrote:
>> On 03/07/2013 12:21 PM, Vlad Yasevich wrote:
>>> Macvlan already supports hw address filters.  Set the IFF_UNICAST_FLT
>>> so that it doesn't needlesly enter PROMISC mode when macvlans are
>>> stacked.
>>
>> Out of curiosity, how can stacking mac-vlans be useful?
>>
>> (You are stacking more macvlans on a base mac-vlan?)
>
> Yep, and macvlans allows, but it looks like it only tries to detect a 2
> level stack.  I am not sure what the reason is.  Might be realated to
> vlan-to-vlan communication.

Aha.  The reason is explained in this commit.

commit b0832a2961022a076c812384435b5f0290b3fc91
Author: Eric Biederman <ebiederm@aristanetworks.com>
Date:   Fri Mar 13 13:15:37 2009 -0700

     macvlan: Support creating macvlans from macvlans

     When running in a network namespace whose only link to
     the outside world is a macvlan device, not being
     able to create another macvlan is a real pain.

     So modify macvlan creation to allow automatically forward
     a creation of a macvlan on a macvlan to become a creation
     of a macvlan on the underlying network device.


I don't know if it's useful to support more then 2 levels.

-vlad

>
> -vlad
>
>>
>> Thanks,
>> Ben
>>
>
