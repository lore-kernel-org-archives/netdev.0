From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 08/11] net: rocker: add get flow API operation
Date: Tue, 6 Jan 2015 08:57:55 -0800
Message-ID: <CAE4R7bDUiLGQnEHs1jemqjrQkzObN5jCkAa3LdWr90KGysrm5w@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194852.31070.72727.stgit@nitbit.x32>
	<CAE4R7bCfpiCaiUwkOnPhHTRPJ3szcLtN8V8E35r=vKJ6rvTt3A@mail.gmail.com>
	<54ABF85F.2080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:50548 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbbAFQ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 11:57:56 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so5766591wid.9
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 08:57:55 -0800 (PST)
In-Reply-To: <54ABF85F.2080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 6:59 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 01/05/2015 11:40 PM, Scott Feldman wrote:
>>
>> On Wed, Dec 31, 2014 at 11:48 AM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>>>
>>> Add operations to get flows. I wouldn't mind cleaning this code
>>> up a bit but my first attempt to do this used macros which shortered
>>> the code up but when I was done I decided it just made the code
>>> unreadable and unmaintainable.
>>>
>>> I might think about it a bit more but this implementation albeit
>>> a bit long and repeatative is easier to understand IMO.
>>
>>
>> Dang, you put a lot of work into this one.
>>
>> Something doesn't feel right though.  In this case, rocker driver just
>> happened to have cached all the flow/group stuff in hash tables in
>> software, so you don't need to query thru to the device to extract the
>> if_flow info.  What doesn't feel right is all the work need in the
>> driver.  For each and every driver.  get_flows needs to go above
>> driver, somehow.
>
>
> Another option is to have a software cache in the flow_table.c I
> was trying to avoid caching as I really don't expect 'get' operations
> to be fast path and going to hardware seems good enough for me.
> Other than its a bit annoying to write the mapping code.

Caching in flow_table.c seems best to me as drivers/devices don't need
to be involved and the cache can server multiple users of the API.
Are there cases where the device could get flow table entries
installed/deleted outside the API?  For example, if the device was
learning MAC addresses, and did automatic table insertions.  We worked
around that case with the recent L2 swdev support by pushing learned
MAC addrs up to bridge's FDB so software and hardware tables stay
synced.
