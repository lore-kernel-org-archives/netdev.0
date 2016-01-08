From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Fri, 8 Jan 2016 14:53:42 -0800
Message-ID: <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:44057 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbcAHWyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 17:54:06 -0500
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id D731A47E98F
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 23:53:46 +0100 (CET)
Received: from mfilter33-d.gandi.net (mfilter33-d.gandi.net [217.70.178.164])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 2A48C41C074
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 23:53:45 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter33-d.gandi.net (mfilter33-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id YDYwS1kTUGEX for <netdev@vger.kernel.org>;
	Fri,  8 Jan 2016 23:53:43 +0100 (CET)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id C8FA341C07F
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 23:53:43 +0100 (CET)
Received: by mail-io0-f174.google.com with SMTP id g73so103613832ioe.3
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 14:53:43 -0800 (PST)
In-Reply-To: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> Currently the ovs internal vports always use a default needed_headroom.
> This leads to a skb head copy while xmitting on ovs swith via vport
> that add some kind of encapsulation (gre, geneve, etc.).
>
> This patch add book-keeping for the maximum needed_headroom used by
> the non internal vports in any dp, updating it on vport creation and
> deletion.
>
> Said value is than used as needed_headroom for internal vports,
> avoiding the above copy.
>
Why is this done only for internal devices? In most common case of
traffic the packet enters OVS from tap or other netdev type vport
device.

> With ~1000 bytes long frames, this give about a 6% xmit performance
> improvement in case of vxlan tunnels and about 8% when using geneve
> tunnels.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Flavio Leitner <fbl@sysclose.org>
> --
