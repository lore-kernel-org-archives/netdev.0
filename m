From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: Convert int functions to bool
Date: Thu, 14 Sep 2017 01:31:58 +0300
Message-ID: <20170913223158.GA7860@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35107 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdIMWcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 18:32:02 -0400
Received: by mail-wr0-f193.google.com with SMTP id n64so751236wrb.2
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 15:32:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Global function ipv6_rcv_saddr_equal and static functions
> ipv6_rcv_saddr_equal and ipv4_rcv_saddr_equal currently return int.
>
> bool is slightly more descriptive for these functions so change
> their return type from int to bool.

>From code generation POV "int" is better for non-inlined functions
especially on non-x86.

Patch bloats even x86_64:

	$ ./scripts/bloat-o-meter ../vmlinux-002-do-while ../obj/vmlinux
	add/remove: 0/0 grow/shrink: 2/0 up/down: 3/0 (3)
	function                                     old     new   delta
	inet_rcv_saddr_equal                          38      40      +2
	inet_csk_get_port                           1300    1301      +1
	Total: Before=6084708, After=6084711, chg +0.00%
