From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: Loopback properties in routing on linux kernel
Date: Tue, 7 Jun 2016 13:23:21 +0200
Message-ID: <d696a6da-022a-654a-d676-03e70df145aa@stressinduktion.org>
References: <CAE+=0-gQEwaAz79HoRsQGjvuTjiCR3cBdOYgbhX19HNiGuU1rg@mail.gmail.com>
 <CAE+=0-jQo14t232RVsV2o=BmbX3T0kphAjbvaAhT3cnxzc5gqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Krishna Mohan <krishnamohany3k@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40349 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754008AbcFGLXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 07:23:24 -0400
In-Reply-To: <CAE+=0-jQo14t232RVsV2o=BmbX3T0kphAjbvaAhT3cnxzc5gqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.06.2016 12:46, Krishna Mohan wrote:
> HI All,
>     I have a question to determine the uses of multiple loopbacks
> interfaces(int loopback) in routing(quagga) on linux kernel. Please
> apologise if it is a dumb question. This is what I understand, please
> clarify if my understanding is correct.
> 
> 1. we need them to represent a /32 ip, normally used for router-id.
> 2. we can measure traffic destined to that ip, via its independent
> statistics per loopback interface.
> 3. ip unnumbered uses loopbacks to represent that ip.
> 
> my question is, is it necessary to have ifindex per loopback interface
> we create? if I create kernel loopback as lo:1 (as subinterface on
> default loopback in kernel) with ip assigned to it will do 1. for
> getting 2 and 3 done, loopback needs to be a separate netdev. is that
> correct?

That is correct, you can terminate the ip addresses for iBGP (or
router-id in this case) connections easily on any ip address that is
bound to some interface within the kernel. Note, that you don't
necessarily get the statistics correctly updated if you short-cut the
packet internally in the kernel. So the statistics on the dummy or
loopback device might not be accurate in such a setup.

> Will I be having any advantage if I configure the interface as lo:1 vs
> a separate netdev per loopback interface (i mean dummy netdev) to
> terminate the /32 destined traffic?

>From kernel PoV it doesn't matter. It is a question of taste and what
your tools prefer.

Bye,
Hannes
