From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Fri, 9 Sep 2016 16:54:19 -0700
Message-ID: <fdd9466d-560d-7261-4c1e-a23d421b2c3c@gmail.com>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
 <20160908083920.0d421951@xeon-e3>
 <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name>
 <9f5db5b9-37dc-91c0-70e2-38644cc5bdb7@gmail.com>
 <20160908141626.0ae9025a@xeon-e3>
 <63AE46DA-1F36-426E-A1D4-AF95E7646177@herrendoerfer.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32880 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcIIXyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:54:22 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so4636987pfb.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:54:22 -0700 (PDT)
In-Reply-To: <63AE46DA-1F36-426E-A1D4-AF95E7646177@herrendoerfer.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2016 01:51 AM, D. Herrendoerfer wrote:
>> just like neighbor table modifications, it should be possible to listen for
>> events with netlink. Doing it through uevent is the wrong model.
> 
> I agree partially - but consider:
> we plug hardware - we get an event
> we remove hardware - we get an event
> we add a virtual interface - we get an event
> we add a bridge - event
> we add an interface to that bridge - event 
> a kvm guest starts using the interface on that bridge - we need to monitor netlink, poll brforward, capture traffic

Yes, because now there is network activity going on, so why not ask the
networking stack to get these events?

> 
> It seems inconsistent, bridge is already emitting events.

It does not seem particularly inconsistent, all networking events are
already emitted using rt netlink, why should bridge be different here?
(Yes, uevent is netlink too, just a special family).

-- 
Florian
