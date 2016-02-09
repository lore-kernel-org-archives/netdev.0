From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Tue, 9 Feb 2016 03:06:14 -0800
Message-ID: <56B9C826.3020502@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160204091656.GA2198@nanopsycho.orion> <20160204231927.GA2347@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, ogerlitz@mellanox.com, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33735 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbcBILHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 06:07:08 -0500
Received: by mail-ob0-f172.google.com with SMTP id is5so181630039obc.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 03:07:08 -0800 (PST)
In-Reply-To: <20160204231927.GA2347@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/4/2016 3:19 PM, Pablo Neira Ayuso wrote:
> On Thu, Feb 04, 2016 at 10:16:56AM +0100, Jiri Pirko wrote:
>> Wed, Feb 03, 2016 at 10:27:32AM CET, john.fastabend@gmail.com wrote:
>>>
>>> Also by adding get_parse_graph and set_parse_graph attributes as
>>> in my previous flow_api work we can build programmable devices
>>> and programmatically learn when rules can or can not be loaded
>>> into the hardware. Again future work.
>>>
>>> Any comments/feedback appreciated.

Sorry if you get this twice it doesn't look like my original response
made it to netdev and the laptop I replied on charger blew up.

>>
>> I like this being thin and elegant solution. However, ~2 years ago when I
>> pushed openvswitch kernel datapath offload patchset, people were yelling
>> at me that it is not generic enough solution, that tc has to be able
>> to use the api (Jamal :)), nftables as well.
>

The other problem with OVS is if you have the capabilities to do
wildcard lookups (e.g. TCAM/SRAM/etc) then offloading the exact
match table in OVS is really inefficient use of the resource. You
really want to load the megaflow table into hardware. I just don't
think its a good scheme for what you want.

> I would be glad to join this debate during NetDev 1.1 too.
>

great.

> I think we should provide a solution that allows people uses both
> tc and nftables, this would require a bit of generic infrastructure on
> top of it so we don't restrict users to one single solution, in other
> words, we allow the user to select its own poison.
>
>> Now this patch is making offload strictly tc-based and nobody seems to
>> care :) I do. I think that we might try to find some generic middle
>> layer.

If we can build the universal model for 'tc' and 'nftable' we should
unify them higher in the stack? It doesn't make sense to me for the
driver folks to try and create the unified model for two subsystems
if we don't think its worthwhile in software as well.

>
> I agree and I'll be happy to help to push this ahead. Let's try to sit
> and get together to resolve this.

Great.

>
> See you soon.
>
