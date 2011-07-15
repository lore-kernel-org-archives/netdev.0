From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: RE: gianfar vlan
Date: Fri, 15 Jul 2011 09:59:03 +0200
Message-ID: <1310716743.1789.9.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: sandeep.kumar@freescale.com, sandeep.kumar@freescale.com,
	netdev@vger.kernel.org, jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:53856 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964952Ab1GOH7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 03:59:10 -0400
Received: by fxd18 with SMTP id 18so2429607fxd.11
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 00:59:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jirka!

The rx queue filer table also needs the RCTRL_PRSDEP_INIT to be set. So I would suggest to add FILREN to RCTRL_REQ_PARSER.

Further I guess the parser should only be enabled if it is necessary (because of VLAN, IP, TCP or FILREN acceleration modes).

What about putting the

if (tempval & RCTRL_REQ_PARSER)
	tempval |= RCTRL_PRSDEP_INIT;
else
	tempval &= ~RCTRL_PRSDEP_INIT;

in a dedicated routine and call it every time one of the four features is altered?

Greetings
Sebastian

> Hi Sandeep.
> 
> I'm trying to remove gfar_vlan_rx_register() and move the vlan accel
> enabling/disabling to gfar_set_features() -> startup_gfar() ->
> gfar_init_mac(). I'm not sure how to handle following lines in
> gfar_vlan_rx_register():
> 
> /* If parse is no longer required, then disable parser */
> if (tempval & RCTRL_REQ_PARSER)
> tempval |= RCTRL_PRSDEP_INIT;
> else
> tempval &= ~RCTRL_PRSDEP_INIT;
> 
> Should this be done only on disabling vlan accel (both rx an tx)?
> Or can I just do that always in startup_gfar() ?
> 
> Thanks.
> 
> Jirka

