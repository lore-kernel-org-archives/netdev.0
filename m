From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: cls_matchall and port mirroring questions
Date: Sat, 28 Jan 2017 16:55:31 +0100
Message-ID: <20170128155531.GA1770@nanopsycho>
References: <f310a430-cd20-f0b0-801c-49376ca20acb@gmail.com>
 <20170128141904.GB2620@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        yotamg@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35856 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdA1Qwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 11:52:31 -0500
Received: by mail-wm0-f66.google.com with SMTP id r126so65895661wmr.3
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 08:50:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170128141904.GB2620@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 28, 2017 at 03:19:04PM CET, idosch@mellanox.com wrote:
>On Thu, Jan 26, 2017 at 07:00:50PM -0800, Florian Fainelli wrote:
>> Hi,
>> 
>> As I am adding support for cls_matchall in the b53/bcm_sf2 drivers, I
>> was looking into several, yet unrelated things:
>> 
>> - mlxsw does not seem to specify whether the port used for capture
>> remains usable, or blocks non-mirror traffic ingressing/egressing it, do
>> we want a control knob for that? If not, what is a sensible default,
>> block all non capture traffic?
>
>Doesn't make sense to me to add such a default. It's up to the user.
>
>> - do we have an updated man page for tc-matchall.8 that features how to
>> use the statistical sampler too? b53 switches have a divider that allows
>> us to select how many frames we want to receive (10 bit value).
>
>https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=5c5670fae43027778e84b9d9ff3b9d91a10a8131
>
>Yotam (Cced) already commented that he intends to send iproute patches.
>
>> - b53 supports capture against a particular MAC SA or DA (or both), do
>> we want to be able to control that somehow?
>
>Can't you just use flower (for example) instead of matchall in that
>case?

Definitelly. No extensions to matchall, as otherwise it could not be
called like that anylonger:)


>
>> What about Marvell switches, what can they do?
>
>No idea :)
>
>> -  a fair amount of code dealing with the cls_matchall mirroring entry
>> is not switch driver specific, in fact, the only things that are switch
>> driver specific are:
>> 	- list pointer where to store this entry (typically in the private
>> network device context)
>> 	- operation to check whether the device belongs to us (identical
>> netdev_ops)
>> 	- retrieval of the destination port number (to_port) which is also
>> typically available in network device private context
>> 
>> Do we want to move a fair amount of code into switchdev, treat
>> cls_matchall entries as a specific switchdev object, and have drivers
>> take over at the same level that mlxsw_sp_port_add_cls_matchall_mirror()
>> currently starts?
>
>I prefer the current way in which we re-use as many as possible core
>APIs without adding switchdev-specific code. I don't have a concrete
>argument against your proposal, though.

This (tc-offload) is completely unrelated to switchdev. So it would make
no sense.
