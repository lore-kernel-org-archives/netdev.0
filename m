From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 7/7] openvswitch: Pack struct sw_flow_key.
Date: Mon, 6 Feb 2017 23:15:30 -0800
Message-ID: <CAPWQB7GF8Zy8qskmKu5sNhj2q93pqwK_-Cd20Qm0yZRNvgbZqA@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-7-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:44368 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdBGHPz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:15:55 -0500
Received: from mfilter31-d.gandi.net (mfilter31-d.gandi.net [217.70.178.162])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id EFFC641C074
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 08:15:52 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter31-d.gandi.net (mfilter31-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 0h3Qgy1PjxGZ for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 08:15:51 +0100 (CET)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 6DDA541C084
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 08:15:51 +0100 (CET)
Received: by mail-qk0-f176.google.com with SMTP id 11so79555055qkl.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:15:51 -0800 (PST)
In-Reply-To: <1486084206-109903-7-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
> struct sw_flow_key has two 16-bit holes. Move the most matched
> conntrack match fields there.  In some typical cases this reduces the
> size of the key that needs to be hashed into half and into one cache
> line.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Looks like this misses the zeroing in ovs_nla_get_flow_metadata();
might want to double-check for any other memset/copies of the key->ct
field.
