From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 0/5] bridge/ovs: avoid skb head copy on frame forwarding
Date: Mon, 29 Feb 2016 11:05:18 -0800
Message-ID: <CAOrHB_BGC2JnW=z0XYri-VioXsqY1tEuPpT1Ft1AStgU=Omfyg@mail.gmail.com>
References: <cover.1456412101.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:55838 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcB2TFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:05:23 -0500
Received: from mfilter21-d.gandi.net (mfilter21-d.gandi.net [217.70.178.149])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id 288701720AF
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 20:05:21 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter21-d.gandi.net (mfilter21-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id QoXHBs-1On9f for <netdev@vger.kernel.org>;
	Mon, 29 Feb 2016 20:05:19 +0100 (CET)
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id A20B51720A3
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 20:05:19 +0100 (CET)
Received: by mail-ig0-f169.google.com with SMTP id g6so2691296igt.1
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 11:05:19 -0800 (PST)
In-Reply-To: <cover.1456412101.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 1:45 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> Currently, while when an OVS or Linux bridge is used to forward frames towards
> some tunnel device, a skb_head_copy() may occur if the ingress device do not
> provide enough headroom for the tx encapsulation.
>
> This patch series tries to address the issue implementing a new ndo operation to
> allow the master device to control the headroom used when allocating the skb on
> frame reception.
>
> Said operation is used by the Linux bridge to notify the bridged ports of
> needed_headroom changes, and similar bookkeeping and behaviour is also added to
> openvswitch, on a per datapath basis.
>
> Finally, the operation is implemented for veth and tun device, which give
> performance improvement in the 6-12% range when forwarding frames from said
> devices towards a vxlan tunnel.
>
> v2:
> - fix netdev_get_fwd_headroom() behaviour
> - remove some code duplication with the netdev_set_rx_headroom() and
>    netdev_reset_rx_headroom() helpers
> - handle headroom reset on [v]port removal/deletion
> - initialize tun align to the old default value
>
> v3:
> - fix a comment typo
>
Patch series looks good to me.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
