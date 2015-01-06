From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 08/11] net: rocker: add get flow API operation
Date: Mon, 5 Jan 2015 23:40:05 -0800
Message-ID: <CAE4R7bCfpiCaiUwkOnPhHTRPJ3szcLtN8V8E35r=vKJ6rvTt3A@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194852.31070.72727.stgit@nitbit.x32>
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
Received: from mail-we0-f182.google.com ([74.125.82.182]:42988 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbbAFHkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 02:40:07 -0500
Received: by mail-we0-f182.google.com with SMTP id w62so9117154wes.13
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 23:40:06 -0800 (PST)
In-Reply-To: <20141231194852.31070.72727.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:48 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> Add operations to get flows. I wouldn't mind cleaning this code
> up a bit but my first attempt to do this used macros which shortered
> the code up but when I was done I decided it just made the code
> unreadable and unmaintainable.
>
> I might think about it a bit more but this implementation albeit
> a bit long and repeatative is easier to understand IMO.

Dang, you put a lot of work into this one.

Something doesn't feel right though.  In this case, rocker driver just
happened to have cached all the flow/group stuff in hash tables in
software, so you don't need to query thru to the device to extract the
if_flow info.  What doesn't feel right is all the work need in the
driver.  For each and every driver.  get_flows needs to go above
driver, somehow.

Seems the caller of if_flow already knows the flows pushed down with
add_flows/del_flows, and with the err handling can't mess it up.

Is one use-case for get_flows to recover from a fatal OS/driver crash,
and to rely on hardware to recover flow set?  In this rocker example,
that's not going to work because driver didn't get thru to device to
get_flows.  I think I'd like to know more about the use-cases of
get_flows.

-scott
