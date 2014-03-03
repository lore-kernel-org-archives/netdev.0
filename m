From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] [PATCH 4/4] ieee802154: remove seq member
 of mac_cb
Date: Mon, 3 Mar 2014 15:34:43 +0100
Message-ID: <20140303153443.1529d06a@zoidberg>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140303140601.GB24286@omega>
	<20140303141026.GA22241@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:38273 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbaCCOe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:34:58 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s23EYttA003430
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 15:34:56 +0100
In-Reply-To: <20140303141026.GA22241@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2014 15:10:27 +0100
Alexander Aring <alex.aring@gmail.com> wrote:

> Or maybe we can move the dev_hard_header call in lowpan_fragment_xmit
> and lowpan_xmit if this is possible. But then we doesn't know the mac
> header length in lowpan_skb_fragmentation. Strange...

You could have lowpan_fragment_xmit create an entirely new skb, call
dev_hard_header, determine how many bytes you can pack into that skb
and then do that. If you can transmit that fragment, return the number
of bytes transmitted, if you can't, return -ENOBUFS or whatever seems
more appropriate. Ideally, also ask mac802154 (somehow, not sure how)
about how many bytes you can fit into the fragment instead of using a
fixed maximum fragment size.
