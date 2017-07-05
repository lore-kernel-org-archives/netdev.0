From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 08/12] net: dsa: Remove support for bypass
 bridge port attributes/vlan set
Date: Wed, 5 Jul 2017 12:45:55 -0700
Message-ID: <9b066beb-190f-ddc8-74bd-c59cee98d059@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-9-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35232 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdGETqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:46:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id z45so51246353wrb.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:46:00 -0700 (PDT)
In-Reply-To: <1499268990-19251-9-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> The bridge port attributes/vlan for DSA devices should be set only
> from bridge code. Furthermore, The vlans are synced totally with the
> bridge so there is no need for special dump support.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

I would be more comfortable if we still had a way to dump HW entries by
calling into drivers, because it's useful for debugging, and doing that
using standard tools plus an additional flag for instance:

bridge fdb show

would dump the SW-maintained VLANs, but:

bridge fdb show hw

would dump the HW-maintained VLANs, or any flag name really, but the
point is that we can keep using a standard tool to expose debugging
features. debugfs (or something else) could be used, but was rejected by
David.

Also, technically, it ought to be possible to configure a port's VLAN
membership (although using poor semantics) through e.g: vconfig add
sw0p0 1, which would call ndo_vlan_rx_add_vid() (DSA does not support it
but mlxsw does), and so being able to dump that configuration would be
somehow helpful.
-- 
Florian
