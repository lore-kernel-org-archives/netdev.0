From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with minor fix)
Date: Mon, 19 Jun 2006 12:39:43 -0400
Message-ID: <OF40F3515E.23FE0F1D-ON85257192.005262A3-85257192.005B8764@us.ibm.com>
References: <Pine.LNX.4.64.0606180313320.22401@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akpm@osdl.org, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	davem@davemloft.net, George Wilson <gcwilson@us.ibm.com>,
	herbert@gondor.apana.org.au, jmorris@redhat.com,
	latten@austin.ibm.com, netdev@vger.kernel.org, sds@tycho.nsa.gov,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:5003 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964789AbWFSQjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 12:39:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5JGdkSs016807
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 12:39:47 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5JGdkwF262340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 12:39:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5JGdjkK015351
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 12:39:46 -0400
In-Reply-To: <Pine.LNX.4.64.0606180313320.22401@d.namei>
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> wrote on 06/18/2006 04:04:06 AM:

> On Sun, 18 Jun 2006, Catherine Zhang wrote:
> 
> I'd also mention here that this is to complement the SO_PEERSEC option 
for 
> stream sockets.
> 

OK.


> There's an implementation issue, which I'm sure has been mentioned 
> previously.  This code should not be calling SELinux API functions.
> 
> > @@ -62,6 +70,12 @@ static __inline__ void scm_recv(struct s
> >       if (test_bit(SOCK_PASSCRED, &sock->flags))
> >               put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, 
> sizeof(scm->creds), &scm->creds);
> > 
> > +     if (test_bit(SOCK_PASSSEC, &sock->flags)) {
> > +             err = selinux_ctxid_to_string(scm->sid, &scontext, 
> &scontext_len);
> 
> 

I remember this issue being discussed, but no conclusion was made.  The 
reason that we cannot use socket_getpeersec_dgram directly is that it 
passes skb as the argument, instead of socket.  If we want to reuse the 
same hook for UNIX, then we have to make change to the interface.  I was 
debating on whether I should add another hook for the UNIX domain...

Let me check whether it'll be possible to reuse socket_getpeersec_dgram 
without too much disruption/complicaiton and I will repost.

thanks,
Catherine

