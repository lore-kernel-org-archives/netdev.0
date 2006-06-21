From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 03/06] MLSXFRM: Add security sid to sock
Date: Tue, 20 Jun 2006 20:50:55 -0400
Message-ID: <36282A1733C57546BE392885C06185920132401F@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:23317 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751433AbWFUAxD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:53:03 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static inline void sock_copy(struct sock *nsk, const 
> struct sock *osk)
> > +{
> > +	void *sptr = nsk->sk_security;
> > +
> > +	memcpy(nsk, osk, osk->sk_prot->obj_size);
> > +	nsk->sk_security = sptr;
> 
> I don't get it.  Why do you put sk_security away and then set it back.
> Doesn't memcpy already do this for you?

Nope. It would actually overwrite the pointer, so we put it away before
memcpy
and set it back after memcpy.
