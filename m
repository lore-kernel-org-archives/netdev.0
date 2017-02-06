From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 6/7] openvswitch: Add force commit.
Date: Mon, 6 Feb 2017 09:08:27 -0800
Message-ID: <CAOrHB_DgjJ9cYpnAeS_dtt0d=rTxhtR4wH_OU_o-tunWUHfddQ@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-6-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:45230 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdBFRId (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 12:08:33 -0500
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 6439D41C0A3
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:08:30 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id SAskpWMcxnCS for <netdev@vger.kernel.org>;
        Mon,  6 Feb 2017 18:08:29 +0100 (CET)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id DDED041C0B5
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:08:28 +0100 (CET)
Received: by mail-it0-f53.google.com with SMTP id c7so61175930itd.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 09:08:28 -0800 (PST)
In-Reply-To: <1486084206-109903-6-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 5:10 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Stateful network admission policy may allow connections to one
> direction and reject connections initiated in the other direction.
> After policy change it is possible that for a new connection an
> overlapping conntrack entry already exist, where the connection
> original direction is opposed to the new connection's initial packet.
>
> Most importantly, conntrack state relating to the current packet gets
> the "reply" designation based on whether the original direction tuple
> or the reply direction tuple matched.  If this "directionality" is
> wrong w.r.t. to the stateful network admission policy it may happen
> that packets in neither direction are correctly admitted.
>
Why not have the check in all commit actions? I am not sure in which
case user would not want forced commit considering this can cause
packet admission issue?

> This patch adds a new "force commit" option to the OVS conntrack
> action that checks the original direction of an existing conntrack
> entry.  If that direction is opposed to the current packet, the
> existing conntrack entry is deleted and a new one is subsequently
> created in the correct direction.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
