From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support
 Nokia Slim Modems
Date: Thu, 30 Sep 2010 12:49:53 +0530
Message-ID: <20100930071952.GA21859@bnru01.bnr.st.com>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
 <201009290125.07068.remi.denis-courmont@nokia.com>
 <20100929063219.GA18733@bnru01.bnr.st.com>
 <201009292121.18274.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	STEricsson_nomadik_linux <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:56846 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753927Ab0I3HT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 03:19:59 -0400
Content-Disposition: inline
In-Reply-To: <201009292121.18274.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=E9mi Denis-Courmont,=20

On Wed, Sep 29, 2010 at 20:21:17 +0200, R=E9mi Denis-Courmont wrote:
> It seems to me that you really want to implement the connect() socket=
 call, so=20
> that one of the two endpoints will stand up for the missing controlle=
r.

Yes, implementing connect() socket call would be nice.

> That's=20
> still much cleaner than CREATE and DESTROY ioctl()'s.

I have not introduced any new ioctl()'s as part of Pipe controller
implementation.
The PIPE_CREATE/PIPE_DESTROY/PIPE_ENABLE/PIPE_DISABLE are all provided
as socket options.
So, user-space can call setsockopt for creating/enabling or
disabling/destroying pipe.

Regarding implementing connect() socket call, few queries:
1. It should carry out all the same steps which I am currently doing as=
 part
   of PIPE_CREATE socket option, right?
2. Currently, as part of Pipe controller implementation, user-space
   follows below sequence:-
	socket()
	bind()
	listen()
	setsockopt(PIPE_CREATE)
	accept()

   In the phonet stack pipe controller logic, we wait for PEP_CONNECT_R=
ESP
   from host-pep (GPRS socket or video telephony socket is a host-pep.
   pep_reply sends out the PEP_CONNECT_RESP) and remote-pep (modem),
   negotiate the best flow-control to be used, and then send
   PIPE_CREATED_IND, with selected flow-control to both pipe end-points=
=2E

   I am not sure how the sequence would be when using the connect() soc=
ket
   call.

Thanks for your inputs.

Thanks & regards,
Kumar.
