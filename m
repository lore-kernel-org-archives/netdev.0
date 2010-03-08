From: =?iso-8859-1?Q?Penttil=E4_Mika?= <mika.penttila@ixonos.com>
Subject: TCP_COOKIE_TRANSACTIONS synack data
Date: Mon, 8 Mar 2010 16:27:25 +0200
Message-ID: <2BC93087D531FF4A98881820AFE8AE7B74C409E1C3@jklmail01.ixonos.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.15]:19865
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755136Ab0CHO1j convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 09:27:39 -0500
Received: from mail9-va3 (localhost [127.0.0.1])	by mail9-va3-R.bigfish.com
 (Postfix) with ESMTP id 222E61730112	for <netdev@vger.kernel.org>; Mon,  8
 Mar 2010 14:27:36 +0000 (UTC)
Received: from VA3EHSMHS005.bigfish.com (unknown [10.7.14.241])	by
 mail9-va3.bigfish.com (Postfix) with ESMTP id DF5435E0013	for
 <netdev@vger.kernel.org>; Mon,  8 Mar 2010 14:27:34 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The TCP_COOKIE_TRANSACTIONS synack data seems pretty unsafe atm. 
>From tcp_make_synack():


	u8 *buf = skb_put(skb, cvp->s_data_desired);

	/* copy data directly from the listening socket. */
    	memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);


The skb here is allocated for MAX_TCP_HEADER + 15 and synack data could be as long as TCP_MSS_DEFAULT, panic():ing at the skb_put().

--Mika


