From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 1/6] net: Make vxlan/geneve default udp ports public
Date: Sat, 9 Apr 2016 13:06:18 -0300
Message-ID: <CAEh+42j+y=cKUDNMQrPdHTozz5=P9pmbQOyKir6DOf=wDJvHSg@mail.gmail.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com> <1460207825-3622-2-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ariel.Elior@qlogic.com, Yuval.Mintz@qlogic.com
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58250 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbcDIQGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 12:06:36 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 06CD3202B8
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 16:06:35 +0000 (UTC)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F8BF20260
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 16:06:34 +0000 (UTC)
Received: by mail-qg0-f46.google.com with SMTP id j35so113696791qge.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 09:06:34 -0700 (PDT)
In-Reply-To: <1460207825-3622-2-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 10:17 AM, Manish Chopra <manish.chopra@qlogic.com> wrote:
> Rationale behind this change is that with some OVS configuration
> UDP ports doesn't get notified to the driver using
> .ndo_[add|del]_vxlan_port. So for the driver to work with
> these specific ports in that environment we need to have them configured
> on adapter by default for the required hardware offload support.

I think you are referring to old out of tree code - no version of
upstream OVS does this. In addition, any old code won't work against
the new kernels that would include this driver update anyways so there
won't be a benefit in any case.

Please just use the normal registration mechanism that is already
exposed. I also noticed that in the Geneve case you aren't currently
registering for port notifications and just using the assigned port
number in all cases, which isn't right.
