From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Cavium: Fix MAC address setting in shutdown
 state
Date: Wed, 24 Jun 2015 01:03:39 -0700 (PDT)
Message-ID: <20150624.010339.684070284302424025.davem@davemloft.net>
References: <016f01d0adc4$09237ba0$1b6a72e0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Aleksey.Makarov@caviumnetworks.com,
	sgoutham@cavium.com, thlab.kim@samsung.com, s.dyasly@samsung.com,
	robert.richter@caviumnetworks.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbbFXHvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 03:51:48 -0400
In-Reply-To: <016f01d0adc4$09237ba0$1b6a72e0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Tue, 23 Jun 2015 17:51:06 +0300

> This bug pops up with NetworkManager on Fedora 21. NetworkManager tends to
> stop the interface (nicvf_stop() is called) before changing settings. In
> stopped state MAC cannot be sent to a PF. However, when the interface is
> restarted (nicvf_open() is called), we ping the PF using NIC_MBOX_MSG_READY
> message, and the PF replies back with old MAC address, overriding what we
> had after MAC setting from userspace. As a result, we cannot set MAC
> address using NetworkManager.
> 
> This patch introduces special tracking of MAC change in stopped state so
> that the correct new MAC address is sent to a PF when interface is reopen.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied, thanks.

> - Fixed (actually hand-edited) file permissions to be 644. I occasionally pushed them as 755 to my
> local repo.

You should be sending patches against my repo, or something derived from it,
which therefore has the correct file permissions for these files.
