From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 02/12] net: flow_table: add flow, delete flow
Date: Wed, 14 Jan 2015 06:55:05 -0800
Message-ID: <54B68349.3080603@gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32> <20150113213556.13874.41211.stgit@nitbit.x32> <CAADnVQK0FqxD9iu5UzFu0Pizi9tQPgjmAs3WBbV7y8jk0Sdi5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, simon.horman@netronome.com,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:39097 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbbANOz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 09:55:26 -0500
Received: by mail-oi0-f52.google.com with SMTP id a3so7591738oib.11
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 06:55:26 -0800 (PST)
In-Reply-To: <CAADnVQK0FqxD9iu5UzFu0Pizi9tQPgjmAs3WBbV7y8jk0Sdi5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 03:00 PM, Alexei Starovoitov wrote:
> On Tue, Jan 13, 2015 at 1:35 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> Now that the device capabilities are exposed we can add support to
>> add and delete flows from the tables.
>>
>> The two operations are
>>
>> table_set_flows :
>>
>>    The set flow operations is used to program a set of flows into a
>>    hardware device table. The message is consumed via netlink encoded
>
> should now netlink cmd be called table_set_rules ?
> and s/flow/rule/ everywhere in commit log?
>
>>    message which is then decoded into a null terminated  array of
>>    flow entry structures. A flow entry structure is defined as
>>
>>       struct net_flow_flow {
>
> commit log no longer matches implementation ;)
> should be net_flow_rule ?
>

Oops, I guess I'll update it after waiting a bit for more feedback.

> can you update your .html writeup?

Took a quick scan at this think I caught most cases and some typos
as well.

> I hope to see more real examples in there.

Sure, I'll put together some more interesting examples in the next
day or so.

>
> btw how the whole thing will work with queue splitting from
> your other patch?
>

If one of the actions supported by the device is forward_to_queue() or
forward_to_socket() we can use the API to steer potentially interesting
packets to a user space application for processing.

Going the other way applications could tell the hardware to
drop/mangle/fwd packets. At some point I thought it would be interesting
to use both the the flow API here and the queue splitting from the
other patch with a tool like Suricata.

.John


-- 
John Fastabend         Intel Corporation
