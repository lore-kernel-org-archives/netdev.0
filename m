From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] net: smsc911x: Fix register_netdev, phy startup,
 driver unload ordering
Date: Sun, 4 Sep 2016 00:19:46 +0300
Message-ID: <20eb6c56-c89b-db8b-a19b-f51b2745fffc@cogentembedded.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-3-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35090 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753962AbcICV0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 17:26:55 -0400
Received: by mail-lf0-f45.google.com with SMTP id l131so11056342lfl.2
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 14:25:58 -0700 (PDT)
In-Reply-To: <1472760909-19688-3-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2016 11:15 PM, Jeremy Linton wrote:

> Move phy startup/shutdown into the smsc911x_open/stop routines. This
> allows the module to be unloaded because phy_connect_direct is no longer
> always holding the module use count. This one change also resolves a
> number of other problems.
>
> The link status of a downed interface no longer reflects a stale state.
> Errors caused by the net device being opened before the mdio/phy was
> configured. There is also a potential power savings as the phy's don't
> remain powered when the interface isn't running.
>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

    Wow, this patch has fixed DHCP/NFS boot failure on my Renesas V2H boards!
Thanks again for your work! :-)

MBR, Sergei
