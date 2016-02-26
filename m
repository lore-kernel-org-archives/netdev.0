From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Fri, 26 Feb 2016 14:22:03 -0800
Message-ID: <CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
References: <cover.1456472746.git.jbenc@redhat.com> <20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52560 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497AbcBZWWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 17:22:20 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id EA10A203E3
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 22:22:18 +0000 (UTC)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 41EBD20303
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 22:22:18 +0000 (UTC)
Received: by mail-qg0-f44.google.com with SMTP id b67so76593658qgb.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 14:22:18 -0800 (PST)
In-Reply-To: <20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 11:48 PM, Jiri Benc <jbenc@redhat.com> wrote:
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index c2b2b7462731..ee4f7198aa21 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -464,6 +464,7 @@ enum {
>  enum vxlan_gpe_mode {
>         VXLAN_GPE_MODE_DISABLED = 0,
>         VXLAN_GPE_MODE_L2,
> +       VXLAN_GPE_MODE_L3,

Given that VXLAN_GPE_MODE_L3 will eventually come to be used by NSH,
MPLS, etc. in addition to IPv4/v6, most of which are not really L3, it
seems like something along the lines of NO_ARP might be better since
that's what it really indicates. Once that is in, I don't really see
the need to explicitly block Ethernet packets from being handled in
this mode. If they are received, then they can just be handed off to
the stack - at that point it would look like an extra header, the same
as if an NSH packet is received.
