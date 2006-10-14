From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: getaddrinfo - should accept IPPROTO_SCTP no?
Date: Fri, 13 Oct 2006 17:00:48 -0700
Message-ID: <1160784048.3094.11.camel@w-sridhar2.beaverton.ibm.com>
References: <45300564.2050504@hp.com>
	 <20061013.150924.104036126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:7304 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1752009AbWJNAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 20:00:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9E00m5I018135
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 20:00:48 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9E00mMw272992
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 20:00:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9E00m0u015150
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 20:00:48 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061013.150924.104036126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-10-13 at 15:09 -0700, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 13 Oct 2006 14:30:12 -0700
> 
> > I'm about to see about concocting an additional workaround in
> > netperf for this, but thought I'd ask if my assumption - that
> > getaddrinfo() returning -7 when given IPPROTO_SCTP - is indeed a bug
> > in getaddrinfo().  Or am I just woefully behind in patches or
> > completely offbase on what is correct behaviour for getaddrinfo and
> > hints?
> 
> Since getaddrinfo() is implemented in GLIBC, this is not very
> much a kernel question unless you can point the failure at
> some kernel calls that the GLIBC getaddrinfo() implementation
> makes.

Yes. This needs to be supported in glibc.
I think adding an entry for IPPROTO_SCTP in the following
structure in glibc:getaddrinfo.c should fix it.

static const struct gaih_typeproto gaih_inet_typeproto[] =
{
  { 0, 0, "", 0 },
  { SOCK_STREAM, IPPROTO_TCP, "tcp", 0 },
  { SOCK_DGRAM, IPPROTO_UDP, "udp", 0 },
  { SOCK_RAW, 0, "raw", GAI_PROTO_PROTOANY|GAI_PROTO_NOSERVICE },
  { 0, 0, "", 0 }
};

I will try it out and and submit a patch to glibc.

Thanks
Sridhar

