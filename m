From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: avoid refreshing heartbeat timer too often
Date: Wed, 30 Mar 2016 09:37:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D54DBFFCD@AcuExch.aculab.com>
References: <1459258897-21607-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:54097 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbcC3Ji0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 05:38:26 -0400
In-Reply-To: <1459258897-21607-1-git-send-email-marcelo.leitner@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 29 March 2016 14:42
>
> Currently on high rate SCTP streams the heartbeat timer refresh can
> consume quite a lot of resources as timer updates are costly and it
> contains a random factor, which a) is also costly and b) invalidates
> mod_timer() optimization for not editing a timer to the same value.
> It may even cause the timer to be slightly advanced, for no good reason.

Interesting thoughts:
1) Is it necessary to use a different 'random factor' until the timer actually
   expires?
2) It might be better to allow the heartbeat timer to expire, on expiry work
   out the new interval based on when the last 'refresh' was done.

	David
