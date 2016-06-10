From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net 1/2] ovs/vxlan: fix rtnl notifications on iface deletion
Date: Fri, 10 Jun 2016 10:52:26 -0700
Message-ID: <CAEh+42iyQ-O8QMRkN1T_kp5n3r4HJ8RBL9r6r+cvWK45MA6svg@mail.gmail.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46264 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbcFJRwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 13:52:44 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 698EE20295
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 17:52:42 +0000 (UTC)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7100F2021A
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 17:52:41 +0000 (UTC)
Received: by mail-qg0-f49.google.com with SMTP id l44so38968611qgd.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 10:52:41 -0700 (PDT)
In-Reply-To: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 2:32 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> The function vxlan_dev_create() (only used by ovs) never calls
> rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
> never set to RTNL_LINK_INITIALIZED.
> During the deletion phase, the function rollback_registered_many() sends
> a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.
>
> Fixes: dcc38c033b32 ("openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN")
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Does Geneve need this as well?
