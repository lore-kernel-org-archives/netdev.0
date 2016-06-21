From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: vlan: add support to display
 per-vlan statistics
Date: Tue, 21 Jun 2016 18:11:59 +0200
Message-ID: <5769674F.3090700@cumulusnetworks.com>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160621090141.0c13d12d@xeon-e3> <57696709.7010506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34166 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbcFUQNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:13:49 -0400
Received: by mail-lf0-f52.google.com with SMTP id h129so30999718lfh.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 09:12:01 -0700 (PDT)
In-Reply-To: <57696709.7010506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/16 18:10, Nikolay Aleksandrov wrote:
> On 21/06/16 18:01, Stephen Hemminger wrote:
>> On Mon, 20 Jun 2016 12:13:19 +0200
>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>
>>> This patch adds support for the -statistics (-s) argument to the bridge
>>> vlan show command which will display the per-vlan statistics and the bridge
>>> device each vlan belongs to. The show command filtering options are both
>>> supported, also the man page is updated to explain the new option.
>>> This patch uses the new RTM_GETSTATS interface with a filter_mask to dump
>>> only the bridge vlans. Later we can add support for using the per-device
>>> dump and filter it in the kernel instead.
>>>
>>> Example:
>>> $ bridge -s vlan
>>> port	vlan id	stats
>>> br0	 1	 RX: 33724730 bytes 492075 packets TX: 67409922 bytes 984029 packets
>>> 	 100	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
>>> 	 200	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
>>> 	 300	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
>>> 	 301	 RX: 169562135 bytes 790877 packets TX: 169550926 bytes 790824 packets
>>> br1	 1	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
>>>
>>> Note that it will print the per-vlan statistics for all vlans in a bridge
>>> even if the vlan is only added to ports. Later when we add per-port
>>> per-vlan statistics support, we'll be able to print the exact ports each
>>> vlan belongs to, not only the bridge.
>>>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Thanks, this is a useful tool, but I think the formatting of output may need to be
>> reworked.  The bridge tool works similar to ip command. And in the ip command the
>> -s flag causes additional lines, but does not change the output format.
> 
> Indeed, I agree that it needs refinement.
> 

Or alternatively I can make it:
$ bridge vlan stats
a subcommand instead of using the "-s" argument in order to be consistent.
So it can have its own format.

>>
>> There is also double line spacing in current output, which scrolls off when
>> managing in little VM windows. Plush the port name is too narrow a field width
> 
> The port name width is the same as vlan show - 1 tab and a space.
> 
>>
>> Why not something like:
>>
>> $ bridge vlan
>> port	   vlan ids
>> virbr1	   1 PVID Egress Untagged
>> virbr4	   1 PVID Egress Untagged
>> virbr0	   1 PVID Egress Untagged
>>
>> $ bridge -s vlan
>> virbr1	   1 PVID Egress Untagged
>>              RX: 33724730 bytes 492075 packets
>>              TX: 67409922 bytes 984029 packets
>> virbr0	   1 PVID Egress Untagged
>>              RX: 169562135 bytes 790877 packets 
>>              TX: 169550926 bytes 790824 packets
>>
>> The -d detail flag would also be useful to implement
>>
> 
> Yep, this was one of the formats I tested. The only thing that we currently
> cannot implement is the flags printing as they're not exported via the stats
> utility and really can't be because some of these entries may not exist on
> the bridge device itself and it will get too confusing.
> I left a few padding fields and I can export the flags if the entry exists
> on the bridge device, then some will have the flags while others
> will not, but it still sounds confusing to me. I'd prefer to just leave the
> flags to the normal vlan show. What do you think ?
> 
> With your example:
>  $ bridge -s vlan
>  virbr1	   	1 
>               RX: 33724730 bytes 492075 packets
>               TX: 67409922 bytes 984029 packets
> 
> This way we can later add more fields like broadcast packets or multicast if
> we ever start counting them.
> 
> I'll later add the "-brief" flag and print them on one line since with
> thousands of vlans it comes in handy.
> 
> Cheers,
>  Nik
> 
