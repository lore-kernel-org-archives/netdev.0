From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Wed, 7 Jan 2015 19:40:48 -0800
Message-ID: <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com> <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:43030 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbbAHDlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 22:41:09 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so923889igb.5
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 19:41:08 -0800 (PST)
In-Reply-To: <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 6:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-01-07 at 17:25 -0800, Ani Sinha wrote:
>> hey guys,
>>
>> On Tue, Jan 6, 2015 at 5:56 PM, Ani Sinha <ani@arista.com> wrote:
>> > On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wrote:
>> >
>> >> The sysctl is kept so that scripts reading it don't suddenly stop
>> >> working.  We can't just remove sysctl values.
>> >
>> > Interestingly, one of our scripts did break. It broke because now this
>> > sysctl is only available in the global net namespace and not in the
>> > child namespaces. If not breaking scripts is the fundamental logic in
>> > keeping in sysctl intact, would you guys be open to accepting a patch
>> > where we make this sysctl available for all net namespaces?
>>
>> Any thoughts on this?
>
> AFAIK, this sysctl (and others) always have been global.
>
> Only /proc/sys/net/ipv4/route/flush is per ns

my apologies for not conveying my thoughts clearer. Eric, you are
correct. However, notice that except /proc/sys/net/ipv4/route/flush,
rest of the sysctls are not available from a child net namespace.

>
> namespaces usage can indeed remove some sysctl :
> Only initial namespace show them.

yes, this is what I am talking about.

>
> Presumably the global sysctl could be shadowed as read only, but still
> some scripts expecting them being rw would break anyway.

true but at least those scripts which does only read the values will
continue to function in a child namespace. In our case, our script
only reads the max_size sysctl but since it operates from within a
child namespace, it doesn't find it.

thoughts?
