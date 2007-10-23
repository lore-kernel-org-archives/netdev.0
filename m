From: Dan Williams <dcbw@redhat.com>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Tue, 23 Oct 2007 10:10:18 -0400
Message-ID: <1193148618.8648.22.camel@localhost.localdomain>
References: <20071022005857.GA6317@nineveh.local> <471C6BEC.4010604@sw.ru>
	 <1193068645.30205.22.camel@localhost.localdomain>
	 <20071023121123.GA8125@postel.suug.ch> <471DF28D.3030904@sw.ru>
	 <20071023133823.GB8125@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@sw.ru>, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59628 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbXJWOMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 10:12:12 -0400
In-Reply-To: <20071023133823.GB8125@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-23 at 15:38 +0200, Thomas Graf wrote:
> * Denis V. Lunev <den@sw.ru> 2007-10-23 17:09
> > I have reproduced the problem with one-line test.
> >     ./nl-route-get 192.168.1.1
> > The problem is with this message:
> > 
> > -- Debug: Sent Message:
> > --------------------------   BEGIN NETLINK MESSAGE 
> > ---------------------------
> >   [HEADER] 16 octets
> >     .nlmsg_len = 20
> >     .nlmsg_type = 18 <route/link>
> >     .nlmsg_flags = 773 <REQUEST,ACK,ROOT,MATCH>
> >     .nlmsg_seq = 1193143772
> >     .nlmsg_pid = 8233
> >   [PAYLOAD] 16 octets
> >     00 1d fa 20 00 00 00 00 81 0e 02 00 00 00 00 00       ... ............
> > ---------------------------  END NETLINK MESSAGE 
> > ---------------------------
> > it starts dump and requests ACK.
> 
> libnl sets the ACK bit for all requests unless the application
> disables this behaviour.

Should I make NM disable ACKs for now until it gets fixed?

Dan


