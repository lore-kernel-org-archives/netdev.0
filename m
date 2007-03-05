From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [Mailer-Daemon@rain.florz.dyndns.org: Mail delivery failed:
	returning message to sender]
Date: Sun, 04 Mar 2007 18:46:44 -0600
Message-ID: <1173055606.12398.64.camel@kdsk1.austin.ibm.com>
References: <20070304145617.GI28150@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Florian Zumbiehl <florz@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:49864 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbXCEAqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 19:46:53 -0500
In-Reply-To: <20070304145617.GI28150@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In the current  code SID 0 indicates that the socket is to be un-bound.
Supporting unbinding of the socket was intended to permit the PPPoE
session to be reconnected without closing/reopening the socket; which
would mean that you'd have to re-bind the PPPoE/PPP channel bindings.
Thus it is conceivable to swap or renegotiate PPPoE connection
underneath a PPP connection, hypothetically if anyone ever considered
doing so.  Is that worth it?  I don't know.  One could eliminate that
disconnect behavior and I don't think anyone would care.

I'll conceed that a SID of 0 could appear from outer space.   I've never
seen that happening. The only way I see this being an issue is if a
PPPoE server insists on giving you SID 0 and only SID 0 repeatedly.  And
I've never seen *that* happening.

If you'd really like to pursue this, I'll be happy to review and ack
patches in this regard.  However, I don't see what there is to be
actually gained by pursuing this.   I'm open to being convinced; what is
the motivation behind this?  If there is a real problem here I'll be
glad to get involved in fixing it myself.


-- 
Michal Ostrowski <mostrows@earthlink.net>


On Sun, 2007-03-04 at 15:56 +0100, Florian Zumbiehl wrote:
> ----- Forwarded message from Mail Delivery System <Mailer-Daemon@rain.florz.dyndns.org> -----
> 
> Date: Sun, 04 Mar 2007 15:52:51 +0100
> From: Mail Delivery System <Mailer-Daemon@rain.florz.dyndns.org>
> To: florz@gmx.de
> Subject: Mail delivery failed: returning message to sender
> Delivery-date: Sun, 04 Mar 2007 15:54:05 +0100
> Auto-Submitted: auto-generated
> 
> This message was created automatically by mail delivery software.
> 
> A message that you sent could not be delivered to one or more of its
> recipients. This is a permanent error. The following address(es) failed:
> 
>   mostrows@earthlink.net
>     SMTP error from remote mailer after MAIL FROM:<florz@gmx.de> SIZE=5299:
>     host mx1.earthlink.net [209.86.93.226]: 550 550 Dynamic/zombied/spam IPs blocked. Write blockedbyearthlink@abuse.earthlink.net
> 
> ------ This is a copy of the message, including all the headers. ------
> 
> Return-path: <florz@gmx.de>
> Received: from florz.florz.dyndns.org ([192.168.0.121])
> 	by rain.florz.dyndns.org with esmtp (Exim 4.50)
> 	id 1HNs4n-0006c7-E0; Sun, 04 Mar 2007 15:52:41 +0100
> Received: from florz by florz.florz.dyndns.org with local (Exim 3.35 #1 (Debian))
> 	id 1HNs4k-0000xd-00; Sun, 04 Mar 2007 15:52:38 +0100
> Date: Sun, 4 Mar 2007 15:52:38 +0100
> From: Florian Zumbiehl <florz@gmx.de>
> To: Michal Ostrowski <mostrows@earthlink.net>
> Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
> 	mostrows@speakeasy.net
> Subject: Re: Session ID 0 with PPPoE
> Message-ID: <20070304145238.GH28150@florz.florz.dyndns.org>
> References: <20070304023000.GF28150@florz.florz.dyndns.org> <20070303.210714.07640494.davem@davemloft.net> <1173014727.12398.19.camel@kdsk1.austin.ibm.com>
> Mime-Version: 1.0
> Content-Type: text/plain; charset=us-ascii
> Content-Disposition: inline
> In-Reply-To: <1173014727.12398.19.camel@kdsk1.austin.ibm.com>
> User-Agent: Mutt/1.5.9i
> 
> Hi,
> 
> > >>From the RFC:
> > 
> > 5.4 The PPPoE Active Discovery Session-confirmation (PADS) packet
> > 
> >    When the Access Concentrator receives a PADR packet, it prepares to
> >    begin a PPP session.  It generates a unique SESSION_ID for the PPPoE
> >    session and replies to the Host with a PADS packet.  The
> >    DESTINATION_ADDR field is the unicast Ethernet address of the Host
> >    that sent the PADR.  The CODE field is set to 0x65 and the SESSION_ID
> >    MUST be set to the unique value generated for this PPPoE session.
> > 
> >    The PADS packet contains exactly one TAG of TAG_TYPE Service-Name,
> >    indicating the service under which Access Concentrator has accepted
> >    the PPPoE session, and any number of other TAG types.
> > 
> >    If the Access Concentrator does not like the Service-Name in the
> >    PADR, then it MUST reply with a PADS containing a TAG of TAG_TYPE
> >    Service-Name-Error (and any number of other TAG types).  In this case
> >    the SESSION_ID MUST be set to 0x0000.
> > 
> > 
> > 
> > As you can see from the last paragraph, a session id of 0 implies a
> > rejection of the PADR.  Thus, you can't possibly get a PADS packet that
> > completes and initiates a valid session if the session id is 0.
> > 
> > Note that the RFC does not prohibit all other aspects of the PADS to be
> > structured as if it were a valid success response; the only condition
> > and requirement of a failure mode here is the session id.
> 
> | [...] then it MUST reply with a PADS containing a TAG of TAG_TYPE
> | Service-Name-Error [...]
> 
> !?!
> 
> To my understanding, the indicator is the Service-Name-Error tag, and
> the RFC only states that if such a tag is present (indicating that
> the AC "doesn't like" the requested service name and thus rejects the
> session request), the session id field must be 0x0000 - not that the
> session id field may not be 0x0000 if this tag is not present (which
> would indicate that this is a valid session).
> 
> > Also 0xffff is reserved for future use. Thus it cannot be used as a
> > sentinel value to indicate an invalid session id.
> 
> Well, currently it could (IMO, a connect() specifying 0xffff as the
> session ID should fail anyway as of now as it is not a valid session id
> as per the RFC - and 0xffff in the session id field could be used to mean
> basically anything at the protocol level in the future) - however that
> probably wouldn't be a good choice for extensibility reasons: If at
> some point, a protocol session id field of 0xffff does somehow mean
> something that would sensibly be represented as 0xffff in the session
> id field of the internal data structure, one would have to change the
> code again. So I guess the session id simply shouldn't be overloaded,
> not even with an indication of its validity.
> 
> > Changing this code would require that the user-space component be
> > synchronized with this change; as the socket interface implies that 0 is
> > an invalid/unbound session id. 
> 
> Well, either that or the indication as to whether the session id is
> currently valid should be stored in some different way.
> 
> > Lots of badness will occur if 0 is allowed as a session id, and nothing
> > will be gained because it can't possibly be a valid session id.
> 
> Well, if that was the case, sure. But I still don't see any reason why
> it can't be.
> 
> Florian
> 
> ----- End forwarded message -----
> 


