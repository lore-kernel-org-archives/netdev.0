From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: ipmr: MFC routes when VIF deleted
Date: Sun, 11 Jun 2017 19:34:19 +0300
Message-ID: <9fa9aa78-2281-dce1-3ff1-a76807d75d42@cumulusnetworks.com>
References: <67ef0899-928a-d2cb-bf12-4bea80240dbe@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Donald Sharp <sharpd@cumulusnetworks.com>
To: Yotam Gigi <yotamg@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:33428 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbdFKQeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 12:34:22 -0400
Received: by mail-wr0-f181.google.com with SMTP id v104so73938678wrb.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 09:34:21 -0700 (PDT)
In-Reply-To: <67ef0899-928a-d2cb-bf12-4bea80240dbe@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/17 11:55, Yotam Gigi wrote:
> I have been looking into some weird behavior, and I am not sure whether it is
> a bug or a feature.
> 
> When a VIF with index v gets deleted, the MFC routes does not get updated, which
> means that there can be routes pointing to that VIF. On datapath, when packet
> hits that route, the VIF validity will be checked and will not be sent to that
> device (but still, the route does not get updated).  Now, if the user creates
> another VIF with the same index v but different underlay device, the same route
> will forward the traffic to that device.
> 
> It is relevant to mention that when user adds a MFC route, only the active VIFs
> are used, so the flow of adding a route with dummy VIF indices and then
> connecting those VIF indices to real device is not supported. The only way to
> create a MFC route that has non existing VIFs is to create one with existing
> VIFs and then delete them.
> 
> Do we really want to support that?  To me, it looks like a buggy flow and I
> suggest that upon VIF deletion, the MFC routes will be updated to not point to
> any non existing VIF indices.
> 

Hi Yotam,
I'm not strongly against such change but my feeling is that we shouldn't change it.
I think we shouldn't change it because we cannot guarantee that we won't break some
user-space app that relies on this behaviour or uses it as an optimization.
User-space ipmr apps work in sync with the kernel and are usually the only ones
doing such changes so their internal state will be always valid, and I'd guess
they already deal with this one way or another.
My second argument is a minor one and is about performance. There are some apps
(e.g. pimd) which use interface add/del on interface state change (up/down) and
this could make these ops slower on large setups.

Again I see how this could be helpful and should've probably been like that from the
start, so if other people feel confident we won't break anything then I wouldn't
mind the change.

Thanks,
 Nik
