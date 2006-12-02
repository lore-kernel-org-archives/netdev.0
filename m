From: =?iso-8859-1?Q?Michal_Ruzicka?= <michal.ruzicka@comstar.cz>
Subject: Re: Multiple end-points behind same NAT
Date: Sat, 2 Dec 2006 20:15:05 +0100
Message-ID: <007a01c71646$683a6e10$12a110ac@main>
References: <45709151.6060803@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <dgoeddel@trustedcs.com>, <chanson@trustedcs.com>,
	<bphan@trustedcs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox.netro.cz ([62.240.185.5]:11151 "EHLO mbox.netro.cz")
	by vger.kernel.org with ESMTP id S1424392AbWLBTQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 14:16:45 -0500
To: "Venkat Yekkirala" <vyekkirala@trustedcs.com>,
	<netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

although I'm not a kernel guru I think I've got something to say to this.

>
> I am wondering if 26sec supports NAT-Traversal for multiple
> endpoints behind the same NAT. In looking at xfrm_tmpl it's
> not obvious to me that it's supported, ...

You are looking at the rignt place indeed. Just to make you sure, there is 
really no space to store the port infomation of the tunnel endpoints in the 
xfrm_tmpl structure.
The structure xfrm_state (a kernel structuture for holding SA's) is a bit 
different story though. Although the port information is not stored directly 
in the structure either, there is the encap member pointing to a 
xfrm_encap_tmpl structure which is used to hold the required information.

The consequences of this are:
1) The IKE dameon (or the key manager as it is called in the kernel context) 
can't get the full infomation from the kernel required to be a successful 
initiator in the case of  multiple peers behind the same NAT. (Though you 
might be able to get it working with a single peer behind the NAT if you 
configure the port forwarding at the NAT box carefuly.)

2) If there was an IKE daemon which could be told the required port 
information by some other means then directly by the kernel it should be 
possible to make it work despite the deficiencies of the kernel. I don't 
know if there is any IKE daemon capable of this, but I'm sure racoon can't 
do that.

3) It is possible to get this working the other way around: If the boxes 
behind the NAT were the initiators then it should work just fine at least if 
tunnel mode was used. There are some problems with the transport mode but 
even that can be made to work for certain scenarios.

Regards,
Michal 

