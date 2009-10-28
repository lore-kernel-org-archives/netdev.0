From: Steve Chen <schen@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 08:29:08 -0500
Message-ID: <1256736549.3153.408.camel@linux-1lbu>
References: <1256683583.3153.389.camel@linux-1lbu> <4AE780CB.8070401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:54588 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1752344AbZJ1NVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 09:21:18 -0400
In-Reply-To: <4AE780CB.8070401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-27 at 16:22 -0700, Rick Jones wrote:
> Steve Chen wrote:
> > Multicast packet reassembly can fail
> > 
> > When multicast connections with multiple fragments are received by the same
> > node from more than one Ethernet ports, race condition between fragments
> > from each Ethernet port can cause fragment reassembly to fail leading to
> > packet drop.  This is because packets from each Ethernet port appears identical
> > to the the code that reassembles the Ethernet packet.
> > 
> > The solution is evaluate the Ethernet interface number in addition to all other
> > parameters so that every packet can be uniquely identified.  The existing
> > iif field in struct ipq is now used to generate the hash key, and iif is also
> > used for comparison in case of hash collision.
> > 
> > Please note that q->saddr ^ (q->iif << 5) is now being passed into
> > ipqhashfn to generate the hash key.  This is borrowed from the routing
> > code.
> > 
> > Signed-off-by: Steve Chen <schen@mvista.com>
> > Signed-off-by: Mark Huth <mhuth@mvista.com>
> 
> It has been hours since my last good Emily Litella moment so I'll ask - isn't 
> the combination of source and dest addr, protocol, IP ID and fragment offset 
> supposed to take care of this?  How does the ingress interface have anything to 
> do with it?

Here is the scenario this patch tries to address

<src node> ---->  <switch>  ----> <eth0 dest node>
                            \--->  <eth1 dest node>

For this specific case, src/dst address, protocol, IP ID and fragment
offset are all identical.  The only difference is the ingress interface.
A good follow up question would be why would anyone in their right mind
multicast to the same destination?  well, I don't know.  I can not get
the people who reported the problem to tell me either.   Since someone
found the need to do this,  perhaps others may find it useful too.

Regards,

Steve

