From: jpo234@netscape.net
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 07:48:33 -0500
Message-ID: <8CB45EFE0258939-2F30-B18@webmail-stg-d07.sysops.aol.com>
References: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com> <87ocy7e95w.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m24.mx.aol.com ([64.12.137.5]:59307 "EHLO
	imo-m24.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760614AbZAPMst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 07:48:49 -0500
In-Reply-To: <87ocy7e95w.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi,
I read the rationale in RFC 3542. Unfortunately this makes the 
following assumptions:
1) You know the IP protocol value when you open the socket. This is not 
true in my case because I get packets from a tun device.
2) Packet injection using packet sockets/libpcap provides the same 
functionality. Bad luck that this completely bypasses IPsec and 
netfilter.

To overcome 1) I would have to strip off the IPv6 header and then have 
a separate socket for every next-header value I might encounter. Not 
very appealing.

I know I'm partial right now, but at least the suggestion in the RFC 
that "some other technique, such as the datalink interfaces BPF or 
DLPI, must be used" is misguided.

Regards
  Joerg


-----Original Message-----
From: Andi Kleen <andi@firstfloor.org>
To: jpo234@netscape.net
Cc: netdev@vger.kernel.org
Sent: Fri, 16 Jan 2009 1:18 pm
Subject: Re: Sending complete IPv6 packets without bypassing 
netfilter/IPsec

jpo234@netscape.net writes:

> Hello all,
> the IPv4 socket interface had the nifty IP_HDRINCL option. It seems
> that an IPv6 version of this option is not available. The proposed
> solution for this seems to be to use libpcap to inject the
> packet. Unfortunately this completely bypasses both, netfilter and
> IPsec. So, am I lost or is there a way to do what I want/need?

The theory is (the same on IPv4) is that the socket options should
allow you to specify everything legal you could put into a IPv6 header
by hand.

-Andi

--
ak@linux.intel.com -- Speaking for myself only.





