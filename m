From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v3] gre: set inner_protocol on xmit
Date: Mon, 15 Aug 2016 10:02:10 -0700
Message-ID: <CAOrHB_AgN68VR5+sz+rBtuxo_-dKqzjWu23fXVqMaCV9Ua7sPg@mail.gmail.com>
References: <1471259184-18294-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:46730 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHORCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 13:02:14 -0400
Received: from mfilter43-d.gandi.net (mfilter43-d.gandi.net [217.70.178.174])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 3439241C086
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 19:02:13 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter43-d.gandi.net (mfilter43-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 0HFSNQjjPGMa for <netdev@vger.kernel.org>;
	Mon, 15 Aug 2016 19:02:11 +0200 (CEST)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id B698041C095
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 19:02:11 +0200 (CEST)
Received: by mail-io0-f173.google.com with SMTP id 38so84815136iol.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 10:02:11 -0700 (PDT)
In-Reply-To: <1471259184-18294-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 4:06 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Ensure that the inner_protocol is set on transmit so that GSO segmentation,
> which relies on that field, works correctly.
>
> This is achieved by setting the inner_protocol in gre_build_header rather
> than each caller of that function. It ensures that the inner_protocol is
> set when gre_fb_xmit() is used to transmit GRE which was not previously the
> case.
>
> I have observed this is not the case when OvS transmits GRE using
> lwtunnel metadata (which it always does).
>
> Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
> Cc: Pravin Shelar <pshelar@ovn.org>
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> v3
> * Move logic to gre_build_header() as suggested by Pravin Shelar.
>
> v2
> * Added Alexander's Ack
> * Drop RFC designation
> ---

Acked-by: Pravin B Shelar <pshelar@ovn.org>
