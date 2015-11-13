From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via-velocity skb_over_panic
Date: Sat, 14 Nov 2015 00:21:33 +0100
Message-ID: <20151113232133.GA21633@electric-eye.fr.zoreil.com>
References: <20151113184947.09d57da5@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43333 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbKMXVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 18:21:36 -0500
Content-Disposition: inline
In-Reply-To: <20151113184947.09d57da5@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> So it's possible that some bad packets make the NIC return unexpected
> packet sizes, and the current code can panic on it.
> 
> Any suggestions for better fix?

        if (vptr->flags & VELOCITY_FLAGS_VAL_PKT_LEN) {
                if (rd->rdesc0.RSR & RSR_RL) {

Huh ?

[...]
        velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
[...]
#define VAL_PKT_LEN_DEF     0
/* ValPktLen[] is used for setting the checksum offload ability of NIC.
   0: Receive frame with invalid layer 2 length (Default)
   1: Drop frame with invalid layer 2 length
*/
VELOCITY_PARAM(ValPktLen, "Receiving or Drop invalid 802.3 frame");

*spleen*

RSR_RL should be set on packet length error. You can imnsvho remove the
VELOCITY_FLAGS_VAL_PKT_LEN and VAL_PKT_LEN_DEF stuff altogether.
He who cares about this option should add NETIF_F_RXALL support to the
via-velocity driver.

-- 
Ueimor
