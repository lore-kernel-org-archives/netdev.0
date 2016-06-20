From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next,v4] openvswitch: Add packet len info to upcall.
Date: Mon, 20 Jun 2016 12:44:54 -0700
Message-ID: <CAOrHB_BVo=UHFByGqE9oPKRm0t-FaAT3vNxNSjzJzRL+VADgoA@mail.gmail.com>
References: <1466432777-30305-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:45462 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbcFTTpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 15:45:00 -0400
Received: from mfilter44-d.gandi.net (mfilter44-d.gandi.net [217.70.178.175])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id AB78C41C07F
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 21:44:57 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter44-d.gandi.net (mfilter44-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 2bYvX85JetZa for <netdev@vger.kernel.org>;
	Mon, 20 Jun 2016 21:44:56 +0200 (CEST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 22D5A41C089
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 21:44:56 +0200 (CEST)
Received: by mail-it0-f51.google.com with SMTP id a5so55929608ita.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 12:44:55 -0700 (PDT)
In-Reply-To: <1466432777-30305-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 7:26 AM, William Tu <u9012063@gmail.com> wrote:
> The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
> introduces packet truncation before sending to userspace upcall receiver.
> This patch passes up the skb->len before truncation so that the upcall
> receiver knows the original packet size. Potentially this will be used
> by sFlow, where OVS translates sFlow config header=N to a sample action,
> truncating packet to N byte in kernel datapath. Thus, only N bytes instead
> of full-packet size is copied from kernel to userspace, saving the
> kernel-to-userspace bandwidth.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
> ---
> v3->v4:
> - Add OVS_PACKET_ATTR_LEN only when packet is truncated,
>   This avoid sending extra attribute in the case of miss flow.
> v2->v3:
> - Remove platform specific name.
> - Fix issue when receiving GSO packet
> - Remove skblen in struct dp_upcall_info
> v1->v2:
> - Pass skb->len to userspace instead of cutlen
> ---
Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
