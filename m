From: Oliver Carter <olivercarter_google@yahoo.co.uk>
Subject: Selecting IPsec SAs by port number
Date: Thu, 26 Apr 2007 18:43:01 +0000 (GMT)
Message-ID: <20070426184301.85933.qmail@web27701.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web27701.mail.ukl.yahoo.com ([217.146.177.235]:35320 "HELO
	web27701.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1031442AbXDZSto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 14:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
 
I'm relatively new to Linux, IPsec and this mailing list, so let me know if I've posted to the wrong list or if this mail is out-of-scope.
 
Background
----------
I'm looking to develop an application that will set up IPsec security associations (SAs) and policy on demand and then use those SAs to protect the packets that it sends out. This application doesn't use IKE, it's a proprietary system I'm working on.
 
In this system, there is no requirement to set up SAs as a result of policy demand. SAs and the policy that refers to them will be programmed at the same time, so when the policy-engine tries to find a suitable SA for a packet, one should always be available (or if not, the packet should be dropped).
 
I've been told that there are two alternative Linux Kernel implementations of IPsec (XFRM (native) or KLIPS (*S/WAN)).  I'm trying to understand whether either of these support my requirements already or if not, which one would be closest.
 
Requirements/Questions
----------------------
Multiple SAs need to be supported to a given endpoint (IP address).  The choice of SA (for outbound packets from the same application) is controlled by the transport level ports, so IPsec policy needs to be able to associate a specific SA with a particular flow (flow being src+dest IP address, transport protocol and ports).  
 
1.  Do either of the existing implementations already support this sort of policy?  
 
In an attempt to answer my own question, I've taken a look through the source code of the latest OpenSwan release (2.4.7).  It appears that this is supported through the SADB_X_EXT_ADDRESS_SRC_FLOW and SADB_X_EXT_ADDRESS_DST_FLOW PF_KEYv2 extensions.  These appear to extract the source/dest ports from the PF_KEY sadb_message and build them into the eroute tree.  Then I believe the lookup in ipsec_tunnel_SAlookup() should preferentially match eroute entries that having matching ports, addresses and protocol.  
 
2.  Can anyone confirm or deny my understanding here?

3.  I had previously thought of the PF_KEY interface as SA programming only.  Associating an SA with a flow in this way seems to verge into policy.  Are there any corresponding policy changes I will need to make to get this to work?  

4.  Have I missed anything that would simplify this (such as a socket option that specifies the SA to use for packets sent over this socket)?
 
Any answers appreciated, even if it's an answer along the lines of "this isn't supported - you're on your own". 
 
Regards
 
Oli


      ___________________________________________________________ 
Yahoo! Mail is the world's favourite email. Don't settle for less, sign up for
your free account today http://uk.rd.yahoo.com/evt=44106/*http://uk.docs.yahoo.com/mail/winter07.html 
