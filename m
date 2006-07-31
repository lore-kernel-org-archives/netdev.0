From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Mon, 31 Jul 2006 10:16:51 -0400
Message-ID: <200607311016.52064.paul.moore@hp.com>
References: <36282A1733C57546BE392885C0618592013E80CA@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:11725 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S932340AbWGaORA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 10:17:00 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <36282A1733C57546BE392885C0618592013E80CA@chaos.tcs.tcs-sec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 31 July 2006 8:43 am, Venkat Yekkirala wrote:
> > The NetLabel patch allows administrators to assign specific a CIPSO
> > DOI/configuration to each LSM "domain".  Blindly using the
> > CIPSO tag that the
> > remote host sends could violate the administrator's NetLabel
> > configuration.
> >
> > The current patch reads the CIPSO tag off the child socket,
> > translating the
> > tag according to the CIPSO DOI configuration to arrive at the
> > correct/desired
> > LSM  security attributes.  These LSM security attributes and
> > the "domain" are
> > then used to set the NetLabel on the socket.  In the case
> > where everyone is
> > well behaved this should have no effect on the socket IP
> > options and the
> > packets sent across the wire.  However, in the case of a
> > not-nice remote host
> > the outgoing CIPSO tag may change to match the administrators desired
> > settings.
>
> I wonder if waiting till accept isn't too late though. Perhaps this
> should be done when the openreq is created so the syn-ack and such
> will go out with the right tag?

Stephen Smalley and I had several long discussions about this and my opinion, 
which seemed to be at least acceptable to Stephen, was that it was okay since 
there was no actual data being sent only TCP control messages.  However, like 
I said earlier, the exact details of this are going to change as I am going 
to port the code to use the new accept() LSM hooks so this is really a not 
much of a concern anymore ...

-- 
paul moore
linux security @ hp
