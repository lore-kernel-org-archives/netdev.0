From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: vmw_vsock sk_ack_backlog double decrement bug
Date: Fri, 24 Jun 2016 13:09:18 +0000
Message-ID: <BY2PR0501MB2056DD2972A874DEC66728ECDA2E0@BY2PR0501MB2056.namprd05.prod.outlook.com>
References: <20160623154059.GA2470@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:48027 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751315AbcFXNJV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 09:09:21 -0400
In-Reply-To: <20160623154059.GA2470@stefanha-x1.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

Good catch. Thanks for pointing this out. I'll take care of fixing and =
testing this.
=20
 Thanks,
 J=F8rgen
   =20
________________________________________
=46rom: Stefan Hajnoczi <stefanha@redhat.com>
Sent: Thursday, June 23, 2016 5:40 PM
To: Jorgen S. Hansen
Cc: netdev@vger.kernel.org
Subject: vmw_vsock sk_ack_backlog double decrement bug

Hi Jorgen,
virtio-vsock doesn't use vsock_pending_work() but I may have spotted a
problem that affects the VMCI transport.  I'm not sending a patch
because I can't test it.

1. During vsock_accept() listener->sk_ack_backlog is decremented.
2. vsock_pending_work() will decrement listener->sk_ack_backlog again i=
f
   vsk->rejected.

The result is that sk_ack_backlog can be invalid.  It only happens in
the case where the listener socket has an error.  Maybe in practice it'=
s
not a problem because the server application will close the listener
socket if there is an error...

Stefan
