From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 12:54:28 -0700
Message-ID: <44233399-2cb9-35af-2b93-b0024aac8dc4@gmail.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
 <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
 <20170906164217.GE15315@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37049 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdIFTyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 15:54:40 -0400
Received: by mail-wm0-f42.google.com with SMTP id u26so34874089wma.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 12:54:40 -0700 (PDT)
In-Reply-To: <20170906164217.GE15315@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 09:42 AM, Andrew Lunn wrote:
>>> On the switch asics we work with, the driver has information if the
>>> packet was
>>> forwarded in hardware. This is per packet reason code telling why the
>>> CPU is seeing the packet.
>>> The driver can use this information to reset skb->offload_fwd_mark to
>>> allow software forward.
> 
>> I am not positive this is universally available across different
>> switch vendors.
> 
> It is not universally available. We cannot rely on it being available
> with switches supported by DSA.
> 
> We have a few choices:
> 
> 1) We assume anything the switch forwards to the CPU has also been
>    sent out whatever ports of the switch it needs to. Set
>    offload_fwd_mark.
> 
> 2) We assume anything the switch forwards to the CPU has not gone
>    anywhere else, and the bridge needs to send it out whatever ports
>    it thinks. Don't set offload_fwd_mark.
> 
> 3) We define some rules about what packets the switch should handle,
>    and then do some deep packet inspection to decide if
>    offload_fwd_mark should be set or not.
> 
> I don't see 3) being possible. We are dealing with a fixed silicon
> data path, not something which is fully programmable.
> 
> So it is down to 1) or 2). I've been assuming 1), but maybe we need to
> discuss that as well.

At the very least we should probably move the skb->offload_fwd_mark
setting down into the individual taggers since they should be in a
better position to set it or not based on the switch device they are
driving, this should address, on a per-switch basis whether 2) or 3)
applies to a given switch.

That being said, I have a feeling that the Marvell switches behave a
tiny bit differently than others in that they do not flood broadcast by
default in a given L2 domain.

On b53/bcm_sf2 there is the ability to disable the reception of
broadcast frames on the management/CPU port, and while there is the
ability to configure which ports should be flooded in case of
unicast/multicast lookup failures, I don't see anything for Broadcast,
so I am assuming this will get forwarded by default. Will test with your
patch set later on time permitting.
-- 
Florian
