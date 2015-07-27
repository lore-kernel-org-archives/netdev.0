From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH v4 net-next 1/4] tcp: replace cnt & rtt with struct
 in pkts_acked()
Date: Mon, 27 Jul 2015 11:46:01 -0700
Message-ID: <20150727114601.42fc6b63@urahara>
References: <1437792426-1724090-1-git-send-email-brakmo@fb.com>
	<1437792426-1724090-2-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33340 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747AbbG0Spz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:45:55 -0400
Received: by padck2 with SMTP id ck2so55633572pad.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:45:55 -0700 (PDT)
In-Reply-To: <1437792426-1724090-2-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jul 2015 19:47:03 -0700
Lawrence Brakmo <brakmo@fb.com> wrote:

> Replace 2 arguments (cnt and rtt) in the congestion control modules'
> pkts_acked() function with a struct. This will allow adding more
> information without having to modify existing congestion control
> modules (tcp_nv in particular needs bytes in flight when packet
> was sent).
> 
> As proposed by Neal Cardwell in his comments to the tcp_nv patch.

Adding a layer of indirection makes code changes easier, but makes
the code slower. Arguments are passed in registers, and putting an
additional level of indirection only matters if you can't change
all the CC modules. Since this is the kernel and API compatability
doesn't matter, just pass more arguments.
