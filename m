From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 15:53:44 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AEC1@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: kelly@au1.ibm.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:48910 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S964884AbWDZWzx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:55:53 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Wed, 26 Apr 2006 15:46:58 -0400
> 
>> Oh, there are plenty of examples of filtering within an established
>> connection:  input rules.  I've seen "drop all packets from <these>
>> IPs" type rules frequently.  Victims of DoS use those kinds of rules
>> to stop packets as early as possible.
> 
> Yes, good point, but this applies to listening connections.
> 
> We'll need to figure out a way to deal with this.
> 
> It occurs to me that for established connections, netfilter
> can simply remove all matching entries from the netchannel lookup
> tables. 
> 
> But that still leaves the thorny listening socket issue.
> This may by itself make netfilter netchannel support
> important and that brings up a lot of issues about classifier
> algorithms. 
> 
> All of this I wanted to avoid as we start this work :-)
> 
> We can think about how to approach these other problems and
> start with something simple meanwhile.  That seems to me to
> be the best approach moving forward.
> 
> It's important to start really simple else we'll just keep
> getting bogged down in complexity and details and never
> implement anything.

How does this sound?

The netchannel qualifiers should only deal with TCP packets
for established connections. Listens would continue to be 
dealt with by the existing stack logic, vj_channelizing
only occurring when the the connection was accepted.

The vj_netchannel qualifiers would conceptually take place
before the netfilter rules (to avoid making deployment
of netchannels dependent on netfilter) but their creation
would have to be approved by netfilter (if netfiler was
active). Netfilter could also revoke vj_channel qualifiers.

If the rule is that "if a vj_netchannel rule exists then it
must be ok with netfilter" is actually very easy to implement.
During early development you simply tell the testers "hey,
don't set up any netchannels that netfilter would reject"
and defer implementing enforcement until after the netchannels
code actually works. After all, if it is isn't actually successfully
transmitting or receiving packets yet it can't really be acting
contrary to netfilter policy.



