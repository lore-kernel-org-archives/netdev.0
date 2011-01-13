From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: reuse ip_summed of first fragment for all
 subsequent fragments
Date: Wed, 12 Jan 2011 18:42:20 -0800 (PST)
Message-ID: <20110112.184220.250810179.davem@davemloft.net>
References: <1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
	<20101228.134905.183040321.davem@davemloft.net>
	<84mxn7czz4.fsf@sauna.l.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.lindfors@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932538Ab1AMCls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 21:41:48 -0500
In-Reply-To: <84mxn7czz4.fsf@sauna.l.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Date: Tue, 11 Jan 2011 15:49:19 +0200

> Anyways, socket option SO_NO_CHECK sets sk->sk_no_check. Could this be
> checked before calculating checksums of each fragment? Currently
> udp_push_pending_frames checks this but checksums have already been
> calculated at that point (and the only job left is to sum the
> checksums together). Here's a patch that works for me (=according to
> perf time is no longer spent calculating checksums) but probably
> should be reviewed carefully:

You're now not handling the code block above this one, guarded
by the "if (len <= 0)" check.

You seem to just be peppering checks all over the place rather
than coming up with a coherent, complete, fix for this problem.
