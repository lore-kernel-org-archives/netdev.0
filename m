From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: gianfar vlan
Date: Fri, 15 Jul 2011 11:16:02 +0200
Message-ID: <20110715091600.GA2250@minipsycho.brq.redhat.com>
References: <1310716743.1789.9.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Sebastian =?iso-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965364Ab1GOJQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 05:16:08 -0400
Content-Disposition: inline
In-Reply-To: <1310716743.1789.9.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 15, 2011 at 09:59:03AM CEST, sebastian.belden@googlemail.com wrote:
>Hi Jirka!
>
>The rx queue filer table also needs the RCTRL_PRSDEP_INIT to be set. So I would suggest to add FILREN to RCTRL_REQ_PARSER.
>
>Further I guess the parser should only be enabled if it is necessary (because of VLAN, IP, TCP or FILREN acceleration modes).
>
>What about putting the
>
>if (tempval & RCTRL_REQ_PARSER)
>	tempval |= RCTRL_PRSDEP_INIT;
>else
>	tempval &= ~RCTRL_PRSDEP_INIT;
>
>in a dedicated routine and call it every time one of the four features is altered?

Ok why not. Would you please cook up the patch and post it? Thanks.

Jirka

>
>Greetings
>Sebastian
>
>> Hi Sandeep.
>> 
>> I'm trying to remove gfar_vlan_rx_register() and move the vlan accel
>> enabling/disabling to gfar_set_features() -> startup_gfar() ->
>> gfar_init_mac(). I'm not sure how to handle following lines in
>> gfar_vlan_rx_register():
>> 
>> /* If parse is no longer required, then disable parser */
>> if (tempval & RCTRL_REQ_PARSER)
>> tempval |= RCTRL_PRSDEP_INIT;
>> else
>> tempval &= ~RCTRL_PRSDEP_INIT;
>> 
>> Should this be done only on disabling vlan accel (both rx an tx)?
>> Or can I just do that always in startup_gfar() ?
>> 
>> Thanks.
>> 
>> Jirka
>
