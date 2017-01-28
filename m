From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: cls_matchall and port mirroring questions
Date: Sat, 28 Jan 2017 09:18:22 -0800
Message-ID: <13a43080-dc8f-5dbd-6344-f668bbe6c6c9@gmail.com>
References: <f310a430-cd20-f0b0-801c-49376ca20acb@gmail.com>
 <20170128141904.GB2620@splinter.mtl.com> <20170128155531.GA1770@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        yotamg@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:35297 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdA1RSp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 12:18:45 -0500
Received: by mail-ot0-f193.google.com with SMTP id 65so33966484otq.2
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 09:18:24 -0800 (PST)
In-Reply-To: <20170128155531.GA1770@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/28/17 à 07:55, Jiri Pirko a écrit :
> Sat, Jan 28, 2017 at 03:19:04PM CET, idosch@mellanox.com wrote:
>> On Thu, Jan 26, 2017 at 07:00:50PM -0800, Florian Fainelli wrote:
>>> Hi,
>>>
>>> As I am adding support for cls_matchall in the b53/bcm_sf2 drivers, I
>>> was looking into several, yet unrelated things:
>>>
>>> - mlxsw does not seem to specify whether the port used for capture
>>> remains usable, or blocks non-mirror traffic ingressing/egressing it, do
>>> we want a control knob for that? If not, what is a sensible default,
>>> block all non capture traffic?
>>
>> Doesn't make sense to me to add such a default. It's up to the user.
>>
>>> - do we have an updated man page for tc-matchall.8 that features how to
>>> use the statistical sampler too? b53 switches have a divider that allows
>>> us to select how many frames we want to receive (10 bit value).
>>
>> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=5c5670fae43027778e84b9d9ff3b9d91a10a8131
>>
>> Yotam (Cced) already commented that he intends to send iproute patches.
>>
>>> - b53 supports capture against a particular MAC SA or DA (or both), do
>>> we want to be able to control that somehow?
>>
>> Can't you just use flower (for example) instead of matchall in that
>> case?
> 
> Definitelly. No extensions to matchall, as otherwise it could not be
> called like that anylonger:)

OK, that make sense. I thought of matchall as action that would solely
deal with all port mirroring features, but using flower on top of an
ingress or egress qdisc + src/dst MAC would definitively and I guess
make senses too.

> 
> 
>>
>>> What about Marvell switches, what can they do?
>>
>> No idea :)
>>
>>> -  a fair amount of code dealing with the cls_matchall mirroring entry
>>> is not switch driver specific, in fact, the only things that are switch
>>> driver specific are:
>>> 	- list pointer where to store this entry (typically in the private
>>> network device context)
>>> 	- operation to check whether the device belongs to us (identical
>>> netdev_ops)
>>> 	- retrieval of the destination port number (to_port) which is also
>>> typically available in network device private context
>>>
>>> Do we want to move a fair amount of code into switchdev, treat
>>> cls_matchall entries as a specific switchdev object, and have drivers
>>> take over at the same level that mlxsw_sp_port_add_cls_matchall_mirror()
>>> currently starts?
>>
>> I prefer the current way in which we re-use as many as possible core
>> APIs without adding switchdev-specific code. I don't have a concrete
>> argument against your proposal, though.
> 
> This (tc-offload) is completely unrelated to switchdev. So it would make
> no sense.

That is true, there is a bit of code (allocation of tc entries, parsing
of actions list etc.) that could be made generic; and one could argue
that each tc action programming request could look like some kind of
special switchdev object. I am totally fine keeping things the way they
are though.

Thanks!
-- 
Florian
