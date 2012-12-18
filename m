From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 04/11] bridge: Cache vlan in the cb for faster egress
 lookup.
Date: Tue, 18 Dec 2012 12:50:13 -0500
Message-ID: <50D0ACD5.1060204@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com> <1355342477-4971-5-git-send-email-vyasevic@redhat.com> <20121218090448.69c21daa@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703Ab2LRRum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 12:50:42 -0500
In-Reply-To: <20121218090448.69c21daa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2012 12:04 PM, Stephen Hemminger wrote:
> On Wed, 12 Dec 2012 15:01:10 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> On input, cache the pointer to the bridge vlan info, so that
>> on egress, we have can simply look at the port bitmap instead
>> of traversing a vlan list.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> This isn't going to be safe. Once packet is passed up, the cb[]
> can get overwritten by other things.
>

Right, but only care about it while in bridging code.  We don't look
at it anywhere else...

Or are you saying that cb is not guaranteed to be preserved between 
br_handle_frame_finish and br_forward?

-vlad
