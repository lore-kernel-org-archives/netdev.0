From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 13:20:50 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AE7F@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:29965 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S964861AbWDZUVI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 16:21:08 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Caitlin Bestler wrote:
>> David S. Miller wrote:
>> 
>>> I personally think allowing sockets to trump firewall rules is an
>>> acceptable relaxation of the rules in order to simplify the
>>> implementation.
>> 
>> I agree.  I have never seen a set of netfilter rules that would block
>> arbitrary packets *within* an established connection.
>> 
>> Technically you can create such rules, but every single set of rules
>> actually deployed that I have ever seen started with a rule to pass
>> all packets for established connections, and then proceeded to
>> control which connections could be initiated or accepted.
> 
> Oh, there are plenty of examples of filtering within an established
> connection:  input rules.  I've seen "drop all packets from <these>
> IPs" type rules frequently.  Victims of DoS use those kinds of
> rules to stop packets as early as possible.
> 
> 	Jeff

If you are dropping all packets from IP X, then how was the connection
established? Obviously we are only dealing with connections that
were established before the rule to drop all packets from IP X
was created.

That calls for an ability to revoke the assignment of any flow to
a vj_netchannel when a new rule is created that would filter any
packet that would be classified by the flow.

Basically the rule is that a delegation to a vj_netchannel is
only allowed for flows where *all* packets assigned to that flow
(input or output) would receive a 'pass' from netchannels.

That makes sense.  What I don't see a need for is examing *each*
delegated packet against the entire set of existing rules. Basically,
a flow should either be rule-compliant or not. If it is not, then
the delegation of the flow should be abandoned. If that requires
re-importing TCP state, then perhaps the TCP connection needs to
be aborted.

In any event, if netfilter is selectively rejecting packets in the
middle
of a connection then the connection is going to fail anyway. 




