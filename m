From: Jiri Pirko <jpirko@redhat.com>
Subject: gianfar vlan
Date: Thu, 14 Jul 2011 15:14:27 +0200
Message-ID: <20110714131426.GA11691@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com,
	davem@davemloft.net, B06378@freescale.com
To: sandeep.kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754564Ab1GNNOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:14:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sandeep.

I'm trying to remove gfar_vlan_rx_register() and move the vlan accel
enabling/disabling to gfar_set_features() -> startup_gfar() ->
gfar_init_mac(). I'm not sure how to handle following lines in
gfar_vlan_rx_register():

/* If parse is no longer required, then disable parser */
if (tempval & RCTRL_REQ_PARSER)
	tempval |= RCTRL_PRSDEP_INIT;
else
	tempval &= ~RCTRL_PRSDEP_INIT;

Should this be done only on disabling vlan accel (both rx an tx)?
Or can I just do that always in startup_gfar() ?

Thanks.

Jirka

