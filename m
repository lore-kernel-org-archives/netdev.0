From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 04/11] rocker: add pipeline model for rocker
 switch
Date: Tue, 06 Jan 2015 09:49:50 -0800
Message-ID: <54AC203E.6090805@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194709.31070.16657.stgit@nitbit.x32> <CAE4R7bB6-bKh6EaZXpsXQeLx5A=MCJTCadYQoP2K5cUfOEUiEw@mail.gmail.com> <54AC149A.6040401@gmail.com> <CAE4R7bAHY8=TJ_hZ5X72bB5fca22zg2L8FgKJdRdRZGDWpSvcA@mail.gmail.com>
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
Received: from mail-ob0-f172.google.com ([209.85.214.172]:63238 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216AbbAFRuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:50:04 -0500
Received: by mail-ob0-f172.google.com with SMTP id va8so66713594obc.3
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 09:50:03 -0800 (PST)
In-Reply-To: <CAE4R7bAHY8=TJ_hZ5X72bB5fca22zg2L8FgKJdRdRZGDWpSvcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2015 09:16 AM, Scott Feldman wrote:
> On Tue, Jan 6, 2015 at 9:00 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> On 01/05/2015 11:01 PM, Scott Feldman wrote:
>>>> +
>>>> +struct net_flow_jump_table parse_ethernet[3] = {
>>>> +       {
>>>> +               .field = {
>>>> +                  .header = HEADER_ETHERNET,
>>>> +                  .field = HEADER_ETHERNET_ETHERTYPE,
>>>> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
>>>> +                  .value_u16 = 0x0800,
>
> ETH_P_IP, etc
>
>>>
>>>
>>> How is htons/ntohs conversions happening here?
>>
>>
>> my current stance is to leave everything in host order in the model
>> and let the drivers do conversions as needed. For example some drivers
>> want the vlan vid in host order others network order. I think its
>> more readable above then with hton*() throughout.
>
> Hmmm...I would argue adding htons/htonl makes it more readable in the
> sense that it's a reminder that this is a field in a network header,
> to be used for matching against packet headers, which use
> network-ordering.  Store the field in the order best for comparison
> with the raw pkt data.  Drivers may still need to do some conversion
> if the field is programmed in hardware in a diff order.
>

Easy enough here, but then when we set_flows what do we use
network-ordering or host? If it can be network-order in some
cases and host-order in others its hard to resolve pragmatically.
Humans at a CLI can most likely get it right for well known fields
such as VLAN IDs but for less common fields (maybe proprietary)
or management software it gets tricky.

I guess we could add a flag to indicate byte ordering.

-- 
John Fastabend         Intel Corporation
