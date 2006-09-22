From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 6/7] [DCCP]: Fix setting of packet size in CCID3
Date: Fri, 22 Sep 2006 11:51:57 +0100
Message-ID: <200609221151.57230@strip-the-willow>
References: <200609221432.20022.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:32439 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S932163AbWIVKwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 06:52:10 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221432.20022.ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Ian McDonald:
|  Set initial packet size to defaults as existing code doesn't work
|  as set_sockopt occurs after initialisation so dccps_packet_size
|  is of no use really.
Please see comments to patch 5/7; rather than setting a default,
ccid3hc{rx,tx}_s should be derived from incoming/outgoing effective
packet sizes.

|  +	case DCCP_SOCKOPT_TX_PACKET_SIZE:
|  +		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
|  +			err = -EINVAL;
This is unfortunate: it is in the generic dccp code but
works only for CCID 3. Same for DCCP_SOCKOPT_RX_PACKET_SIZE.


--Gerrit
