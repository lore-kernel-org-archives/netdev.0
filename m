From: jpo234@netscape.net
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 00:48:40 -0500
Message-ID: <8CB45B537A78CBC-E08-15F7@webmail-stg-d04.sysops.aol.com>
References: <20090115235416.GA8862@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m20.mx.aol.com ([64.12.137.1]:54534 "EHLO
	imo-m20.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbZAPFt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 00:49:58 -0500
In-Reply-To: <20090115235416.GA8862@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert,
thanks for taking the time to answer. I thought about this, but was 
discouraged by the following passage in RFC 3542:

   Most IPv4 implementations give special treatment to a raw socket
   created with a third argument to socket() of IPPROTO_RAW, whose value
   is normally 255, to have it mean that the application will send down
   complete packets including the IPv4 header.  (Note: This feature was
   added to IPv4 in 1988 by Van Jacobson to support traceroute, allowing
   a complete IP header to be passed by the application, before the
   IP_HDRINCL socket option was added.)  We note that IPPROTO_RAW has no
   special meaning to an IPv6 raw socket (and the IANA currently
   reserves the value of 255 when used as a next-header field).

So, if you write "should have the same effect as IP_HDRINCL" does this 
mean "this is the way we designed it in Linux, so it should work" or 
"give it a try, I think it might work". The first one would make me try 
harder than the second one. If it does in fact work, than this should 
be documented more prominently somewhere. I did a long and IMHO 
thorough Google search and found no mention of this.

Thanks and kind reagrds
  Joerg

-----Original Message-----
From: Herbert Xu <herbert@gondor.apana.org.au>
To: jpo234@netscape.net
Cc: netdev@vger.kernel.org
Sent: Fri, 16 Jan 2009 12:54 am
Subject: Re: Sending complete IPv6 packets without bypassing 
netfilter/IPsec

jpo234@netscape.net wrote:
> the IPv4 socket interface had the nifty IP_HDRINCL option. It seems
> that an IPv6 version of this option is not available. The proposed
> solution for this seems to be to use libpcap to inject the packet.
> Unfortunately this completely bypasses both, netfilter and IPsec. So,
> am I lost or is there a way to do what I want/need?

    socket(AF_INET6, SOCK_RAW, IPPROTO_RAW)

should have the same effect as IP_HDRINCL.

Cheers,
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt





