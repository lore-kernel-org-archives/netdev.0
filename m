From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Tue, 25 Sep 2012 07:29:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209250719120.25195@nerf07.vanv.qr>
References: <20120921085502.4534.20232.stgit@dragon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:38307 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab2IYF3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 01:29:23 -0400
In-Reply-To: <20120921085502.4534.20232.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Friday 2012-09-21 10:55, Jesper Dangaard Brouer wrote:
>diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>index c7fc107..684131c 100644
>--- a/Documentation/networking/ip-sysctl.txt
>+++ b/Documentation/networking/ip-sysctl.txt
>@@ -257,6 +257,18 @@ tcp_frto_response - INTEGER
> 		  to the values prior timeout
> 	Default: 0 (rate halving based)
> 
>+tcp_init_recv_window - INTEGER
>+	Default initial advertised receive window.  Actual window size
>+	is this value multiplied by the MSS of the connection.  Its

	is this value multiplied by the MSS of the connection.  It is

>+	possible to control/override this value per route table entry
>+	via the iproute2 option initrwnd.
>+	Minimum value is 1, but 2 is the recommended minimum.
>+	The effective max value, is limited by the sockets receive

	The effective max value is limited by the sockets receive

>+	buffer size (default tcp_rmem[1], and possibly scaled by
>+	tcp_adv_win_scale), and can further be limited by window

	tcp_adv_win_scale) and can further be limited by window

>+	clamp.

	clamping.

>+	Default: 10
>+
> tcp_keepalive_time - INTEGER
> 	How often TCP sends out keepalive messages when keepalive is enabled.
> 	Default: 2hours.

The "recommended minimum" is somewhat strange from a language POV,
since the recommendation is actually to _not touch_ the option at all
(because the default works and there is potential abuse as Dave
mentions).
