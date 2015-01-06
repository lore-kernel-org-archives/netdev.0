From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 08/11] net: rocker: add get flow API operation
Date: Tue, 06 Jan 2015 06:59:43 -0800
Message-ID: <54ABF85F.2080105@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194852.31070.72727.stgit@nitbit.x32> <CAE4R7bCfpiCaiUwkOnPhHTRPJ3szcLtN8V8E35r=vKJ6rvTt3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:60275 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbAFO75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 09:59:57 -0500
Received: by mail-ob0-f182.google.com with SMTP id wo20so65789891obc.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 06:59:57 -0800 (PST)
In-Reply-To: <CAE4R7bCfpiCaiUwkOnPhHTRPJ3szcLtN8V8E35r=vKJ6rvTt3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2015 11:40 PM, Scott Feldman wrote:
> On Wed, Dec 31, 2014 at 11:48 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> Add operations to get flows. I wouldn't mind cleaning this code
>> up a bit but my first attempt to do this used macros which shortered
>> the code up but when I was done I decided it just made the code
>> unreadable and unmaintainable.
>>
>> I might think about it a bit more but this implementation albeit
>> a bit long and repeatative is easier to understand IMO.
>
> Dang, you put a lot of work into this one.
>
> Something doesn't feel right though.  In this case, rocker driver just
> happened to have cached all the flow/group stuff in hash tables in
> software, so you don't need to query thru to the device to extract the
> if_flow info.  What doesn't feel right is all the work need in the
> driver.  For each and every driver.  get_flows needs to go above
> driver, somehow.

Another option is to have a software cache in the flow_table.c I
was trying to avoid caching as I really don't expect 'get' operations
to be fast path and going to hardware seems good enough for me.
Other than its a bit annoying to write the mapping code.

If you don't have a cache then somewhere there has to be a mapping
from hardware flow descriptors to the flow descriptors used by the
flow API. Like I noted I tried to help by using macros and helper
routines but in the end I simply decided it convoluted the code to
much and made it hard to debug.

>
> Seems the caller of if_flow already knows the flows pushed down with
> add_flows/del_flows, and with the err handling can't mess it up.

yes the caller could know if it cached them which it doesn't. We
can add a cache if its helpful. You may have multiple users of the
API (both in-kernel and user space) though so I don't think you can
push it much beyond the flow_table.c.

>
> Is one use-case for get_flows to recover from a fatal OS/driver crash,
> and to rely on hardware to recover flow set?  In this rocker example,
> that's not going to work because driver didn't get thru to device to
> get_flows.  I think I'd like to know more about the use-cases of
> get_flows.

Its helpful for debugging. And if you have multiple consumers it
may be helpful to "learn" what other consumers are doing. I don't
have any concrete cases at the moment though.

For the CLI case its handy to add some flows, forget what you did,
and then do a get to refresh your mind. Not likely a problem for
"real" management software.

At least its not part of the UAPI so we could tweak/improve it as
much as we wanted. Any better ideas? I'm open to suggestions on this
one.

>
> -scott
>


-- 
John Fastabend         Intel Corporation
