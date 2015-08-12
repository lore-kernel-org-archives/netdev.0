From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Wed, 12 Aug 2015 10:23:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
 <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>,
	"tan.hu@zte.com.cn" <tan.hu@zte.com.cn>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	"cluster-devel@redhat.com" <cluster-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:65188 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933212AbbHLKZv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 06:25:51 -0400
In-Reply-To: <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 11 August 2015 23:22
> DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
> needed but this causes it to use sctp_do_peeloff() to mimic an
> kernel_accept() and this causes a symbol dependency on sctp module.
> 
> By switching it to 1-to-1 API we can avoid this dependency and also
> reduce quite a lot of SCTP-specific code in lowcomms.c.
...

You still need to enable sctp notifications (I think the patch deleted
that code).
Otherwise you don't get any kind of indication if the remote system
'resets' (ie sends an new INIT chunk) on an existing connection.

It is probably enough to treat the MSG_NOTIFICATION as a fatal error
and close the socket.

This is probably a bug in the sctp stack - if a connection is reset
but the user hasn't requested notifications then it should be
converted to a disconnect indication and a new incoming connection.

	David
