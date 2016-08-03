From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix method of PTR_TO_PACKET reg id generation
Date: Wed, 03 Aug 2016 11:54:25 -0700 (PDT)
Message-ID: <20160803.115425.1865258080449745277.davem@davemloft.net>
References: <1470150734-24022-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbcHCSzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:55:50 -0400
In-Reply-To: <1470150734-24022-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue,  2 Aug 2016 16:12:14 +0100

> Using per-register incrementing ID can lead to
> find_good_pkt_pointers() confusing registers which
> have completely different values.  Consider example:
 ...
> We need to get a UNKNOWN_VALUE with imm to force id
> generation so lines 0-5 make r7 a valid packet pointer.
> We then read two different bytes from the packet and
> add them to copies of the constructed packet pointer.
> r8 (line 9) and r9 (line 11) will get the same id of 1,
> independently.  When either of them is validated (line
> 13) - find_good_pkt_pointers() will also mark the other
> as safe.  This leads to access on line 14 being mistakenly
> considered safe.
> 
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied and queued up for -stable, thanks.
