From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 5 Jan 2015 22:40:02 -0800
Message-ID: <CAE4R7bCp7NAfi85DNEKbG49xEZnY2xm_GNoeYyrVGMLwpbXvvA@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194544.31070.30335.stgit@nitbit.x32>
	<CAE4R7bBeCbq1yiRHQaQSX4JwKMWxn2hMoOptyOZe3Ak=9WzrVw@mail.gmail.com>
	<54AB7AD3.7050704@gmail.com>
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
Received: from mail-we0-f175.google.com ([74.125.82.175]:34981 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbAFGkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 01:40:04 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so9100233wes.34
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 22:40:02 -0800 (PST)
In-Reply-To: <54AB7AD3.7050704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 10:04 PM, John Fastabend
<john.fastabend@gmail.com> wrote:

>>> + * @uid unique identifier for table
>>> + * @source uid of parent table
>>
>>
>> Is parent table the table previous in the pipeline?  If so, what if
>> you can get to table from N different parent tables, what goes in
>> source?
>
>
> No, you can get the layout of tables from the table graph ops.
>
> Source is used when a single tcam or other implementation mechanism
> is sliced into a set of tables. The current rocker world doesn't use
> this very much at the moment because its static and I just assumed
> every table came out of the same virtual hardware namespace.
>
> A simple example world would be to come up with a set of large virtual
> TCAMs. Any given TCAM maybe sliced into a set of tables. Users may
> organize these either via some out of band configuration at init or
> power on time. In the rocker case we could specify this when we load
> qemu. For now it is just informational. But if we start allowing users
> to create delete tables at runtime it is important to "know" where the
> slices are being allocated/free'd from. The source gives you this
> information.
>
> The hardware devices I'm working on have multiple sources we can
> allocate/free tables from. The source values would provide a way to
> track down which tables are in which hardware namespaces.
>
> Hope that helps?

Got it, thanks.

Can source be encoded in tbl_id?


>> hdr or header?  pick one, probably hdr.
>
>
> hdr is shorter and doesn't lose any clarity IMO I'll use net_flow_hdr
> and net_flow_hdr_node
>
>>
>>> +       struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct
>>> net_device *dev);
>>
>>
>> move this up next to get_tables
>
>
> sure also what do you think tbl instead of table.

+1 for tbl.
