From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 2/7] NetLabel: core network changes
Date: Sat, 29 Jul 2006 12:34:33 -0400
Message-ID: <36282A1733C57546BE392885C0618592013E80BD@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:35179 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932172AbWG2Qf5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 12:35:57 -0400
To: Paul Moore <paul.moore@hp.com>, David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This is only true wart I see in the patch set from my
> > perspective.
> > 
> > You have security_post_accept_hook(), which gets the parent and
> > the child socket which is all the information you need, and it
> > seems to be invoked at the correct location.
> > 
> > So can you please hook into this location using the security
> > level hook we already have?  Just check sock->sk->sk_family is
> > PF_INET at the top of that hook if you only want to handle
> > ipv4 sockets, or something like that.
> > 
> > Could this work?
> > 
> > When preparing and argument stating why this won't work, please
> > suggest a nicer name for this af_inet.c hook or some way to make
> > it more generic and palatable to us.
> 
> The only reason for having this new hook in inet_accept() is to catch
> all the in-kernel "daemons" who do not go through the LSM hooked
> accept() code path.  I debated putting this hook into the patchset and
> in the end figured it was at least worth a shot.

If I understand the patch correctly, the openreq inherits cipso from
the incoming syn and the syn-ack is then sent with this option. I further
see that the child sock inherits options from the openreq already.

Could you then please elaborate on the need for explicitly copying options
from parent to child?
