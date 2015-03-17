From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Tue, 17 Mar 2015 08:00:46 +0100
Message-ID: <20150317070046.GB2042@nanopsycho.orion>
References: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
 <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com>
 <20150309064043.GB2053@nanopsycho.orion>
 <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com>
 <20150309160754.GA2169@nanopsycho.lan>
 <E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com>
 <20150310063926.GA1995@nanopsycho.orion>
 <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com>
 <20150310082817.GC1995@nanopsycho.orion>
 <550752BA.5040702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:34176 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbbCQHAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 03:00:49 -0400
Received: by wegp1 with SMTP id p1so675627weg.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 00:00:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <550752BA.5040702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 11:01:30PM CET, john.fastabend@gmail.com wrote:
>[...]
>
>>
>>>If this position is accepted, it would be best to enforce it, possibly in
>>>rtnl_bridge_setlink().
>>>My recollection is that others asked to preserve use-cases where SELF flag
>>>is used for targeting port devices directly without using a bridge device.
>>
>>I know it is possible, and it is incorrect and hacky. But it is part of
>>user api :/ I think we should not abuse this more in the future and
>>rather make the api correct and use that.
>>
>
>Working my way through my backlog of email sorry for the days delay.
>
>Jiri, are you suggesting it is incorrect to configure the hardware L2
>independent of bridge device? There is absolutely use cases for this.
>
>The case being we want the hardware to do L2 learning via fdb and then
>when flows get 'trapped' into software we want to handle them
>differently. Possibly send them onto a specific application for logging.

Yes, but that can be done in transparent way, exposing hw ports, having
them in bridge/ovs/whatever. Same as we do with rocker.

>
>I'm at a loss around what use "really" running the bridge in software
>is. There shouldn't be packets traversing the software path and if they
>are being sent onto software I really can't think of any use case I
>would want to run them through the software bridge. More likely I want
>to run OVS or some equivalent controller-based software to forward them
>"specially" to the correct software/controller/port.
>
>My current use case is L2/L3 on the hardware, OVS and applications in
>software. I don't think this is broken or hacky. This means no bridge
>in software but programming the L2 bridge in hardware.
>
>.John
>
>
>-- 
>John Fastabend         Intel Corporation
