From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: Add cutlen info to upcall.
Date: Wed, 15 Jun 2016 19:55:40 -0700
Message-ID: <CAOrHB_CNe19U8wSOEAc6zi1+83ZH8GNQ3D+H_syG2SWNS5eUhA@mail.gmail.com>
References: <1466044135-9707-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:59911 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbcFPCzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 22:55:45 -0400
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id B9E17C5A4E
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 04:55:43 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Hl97oB_8-XXH for <netdev@vger.kernel.org>;
	Thu, 16 Jun 2016 04:55:42 +0200 (CEST)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 3EB62C5A51
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 04:55:41 +0200 (CEST)
Received: by mail-io0-f171.google.com with SMTP id t74so30713919ioi.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 19:55:41 -0700 (PDT)
In-Reply-To: <1466044135-9707-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 7:28 PM, William Tu <u9012063@gmail.com> wrote:
> The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
> introduces packet truncation before sending to userspace upcall receiver.
> This patch passes the number of bytes truncated in kernel to so that the
> upcall receiver knows the original packet size. Potentially this will
> be used by sFlow, where OVS translates sFlow config header=N to a sample
> action to trunc(N) in kernel datapath. Thus, only N bytes instead of
> full-packet size will be copied from kernel to userspace, saving the
> kernel-to-userspace bandwidth.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin Shelar <pshelar@nicira.com>

This is passing unnecessary kernel implementation details to
userspace, can we just pass skb-len to userspace?
