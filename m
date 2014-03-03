From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH 4/4] ieee802154: remove seq member
 of mac_cb
Date: Mon, 3 Mar 2014 15:06:02 +0100
Message-ID: <20140303140601.GB24286@omega>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:33691 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbaCCOGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:06:07 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so4469979ead.24
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 06:06:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch is fine. Increment and set of DSN value should be done by
mac802154 layer.

But there is also a known issue with increment of DSN value while
6lowpan fragmentation.

On a fragmented packet 6lowpan calls dev_hard_header once, then many
times lowpan_fragment_xmit, depending on the number of fragments which
is needed.

Each call of lowpan_fragment_xmit will have the same DSN value. Maybe we
should put the increment of DSN in "mac802154/tx.c" before calling xmit
callback from driver (Just an idea). What do you think about that?

- Alex
