From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Tue, 23 Oct 2007 15:38:23 +0200
Message-ID: <20071023133823.GB8125@postel.suug.ch>
References: <20071022005857.GA6317@nineveh.local> <471C6BEC.4010604@sw.ru> <1193068645.30205.22.camel@localhost.localdomain> <20071023121123.GA8125@postel.suug.ch> <471DF28D.3030904@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52802 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbXJWNiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 09:38:03 -0400
Content-Disposition: inline
In-Reply-To: <471DF28D.3030904@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Denis V. Lunev <den@sw.ru> 2007-10-23 17:09
> I have reproduced the problem with one-line test.
>     ./nl-route-get 192.168.1.1
> The problem is with this message:
> 
> -- Debug: Sent Message:
> --------------------------   BEGIN NETLINK MESSAGE 
> ---------------------------
>   [HEADER] 16 octets
>     .nlmsg_len = 20
>     .nlmsg_type = 18 <route/link>
>     .nlmsg_flags = 773 <REQUEST,ACK,ROOT,MATCH>
>     .nlmsg_seq = 1193143772
>     .nlmsg_pid = 8233
>   [PAYLOAD] 16 octets
>     00 1d fa 20 00 00 00 00 81 0e 02 00 00 00 00 00       ... ............
> ---------------------------  END NETLINK MESSAGE 
> ---------------------------
> it starts dump and requests ACK.

libnl sets the ACK bit for all requests unless the application
disables this behaviour.
