From: Ben Greear <greearb@candelatech.com>
Subject: Re: Can libpcap filter on vlan tags when vlans are
 hardware-accelerated?
Date: Tue, 26 Sep 2017 09:41:55 -0700
Message-ID: <b022e7ac-582f-d895-389a-028ee4c81a9c@candelatech.com>
References: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
 <20170912202617.ny3bbi2dthxxffh3@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:36886 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965823AbdIZQlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 12:41:55 -0400
In-Reply-To: <20170912202617.ny3bbi2dthxxffh3@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2017 01:26 PM, Michal Kubecek wrote:
> On Tue, Sep 12, 2017 at 11:54:43AM -0700, Ben Greear wrote:
>> It does not appear to work on Fedora-26, and I'm curious if someone
>> knows what needs doing to get this support working?
>
> It's rather complicated. The "vlan" and "vlan <id>" filters didn't
> handle the case when vlan information is passed in metadata until commit
> 04660eb1e561 ("Use BPF extensions in compiled filters"), i.e. libpcap
> 1.7.0. Unfortunately that commit made libpcap always check only metadata
> for the first outermost vlan tag so that it broke the case when vlan
> information is passed in packet itself (which is less frequent today).
>
> To handle both cases correctly, you would need libpcap with commits
> d739b068ac29 ("Make VLAN filter handle both metadata and inline tags")
> and 7c7a19fbd9af ("Fix logic of combined VLAN test") and also the
> optimizer fix from
>
>   https://github.com/the-tcpdump-group/libpcap/pull/582/commits/075015a3d17a
>
> (without it the filters generate incorrect BPF in some cases unless the
> optimizer is disabled). As far as I can see, these commits are not in
> any release yet.
>
>                                                        Michal Kubecek
>

So, I cloned the latest libpcap, and I'm going to start poking at this.

Do you happen to know if I need to do anything special other than
'pcap_compile()'?  I'm curious how the library would know if it can use
newer kernel API or not...or maybe it is somehow magically backwards/forward
compatible?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
