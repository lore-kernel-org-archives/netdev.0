From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 17:34:32 -0800
Message-ID: <CAHA+R7MppM9WQmN0P=CFe0m0-sL0j9KUQ8CRDmoQ15bG6moq7g@mail.gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<1392247105.15615.41.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:59769 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbaBMBed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 20:34:33 -0500
Received: by mail-lb0-f172.google.com with SMTP id c11so7816542lbj.31
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:34:32 -0800 (PST)
In-Reply-To: <1392247105.15615.41.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 3:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2014-02-11 at 15:51 -0800, Cong Wang wrote:
>> From: Cong Wang <cwang@twopensource.com>
>>
>> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
>>
>> macvlan and vlan both use iflink to identify its lower device,
>> however, after such device is moved to the new netns, its iflink
>> would become meaningless as ifindex is per netns. So, instead of
>> forbid them moving to another netns, just clear this field so that
>> it will not be dumped at least.
> [...]
>
> And what if it's moved back into the same netns?
>

Good point!

> I think iflink should be changed to a net_device pointer, so it remains
> valid for in-kernel users but rtnetlink can do the netns check before
> revealing it to userland.
>

I will try this approach.

Thanks.
