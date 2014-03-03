From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] [PATCH 4/4] ieee802154: remove seq member
 of mac_cb
Date: Mon, 3 Mar 2014 15:12:19 +0100
Message-ID: <20140303151219.42ed91f4@zoidberg>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140303140601.GB24286@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:36617 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbaCCOMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:12:36 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s23ECXYE024340
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 15:12:34 +0100
In-Reply-To: <20140303140601.GB24286@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On a fragmented packet 6lowpan calls dev_hard_header once, then many
> times lowpan_fragment_xmit, depending on the number of fragments which
> is needed.

To me, the obvious answer would be "just don't do that". Each fragment
is a distinct packet, so it should not reuse a header that was created
for another packet in the first place.

> Each call of lowpan_fragment_xmit will have the same DSN value. Maybe
> we should put the increment of DSN in "mac802154/tx.c" before calling
> xmit callback from driver (Just an idea). What do you think about
> that?

That would work. Crypto will have to set it's own frame counter there
anyway, since reordering in the wpan queue would otherwise cause
unexpected packet drops. I don't see that need for the DSN though.
