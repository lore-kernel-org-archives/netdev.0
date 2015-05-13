From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for xen net
 drivers
Date: Wed, 13 May 2015 13:01:51 +0000
Message-ID: <88CC54BC-E6CB-4938-8810-3D371FE07493@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <55532C86.8020409@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:56086 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933410AbbEMNCG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:02:06 -0400
In-Reply-To: <55532C86.8020409@citrix.com>
Content-Language: en-US
Content-ID: <1A42655685B24944B70E95712D858EDA@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 13 May 2015, at 12:50, David Vrabel <david.vrabel@citrix.com> wrote:

> On 12/05/15 18:18, Joao Martins wrote:
>> 
>> Packet I/O Tests:
>> 
>> Measured on a Intel Xeon E5-1650 v2, Xen 4.5, no HT. Used pktgen "burst 1"
>> and "clone_skbs 100000" (to avoid alloc skb overheads) with various pkt
>> sizes. All tests are DomU <-> Dom0, unless specified otherwise.
> 
> Are all these measurements with a single domU with a single VIF?
> 
> The biggest problem with a persistent grant method is the amount of
> grant table and maptrack resources it requires.  How well does this
> scale to 1000s of VIFs?

Correct. I was more focused on throughput benefits with persistent grants,
as opposed to scalability with a large number of guests. I will do more tests
with more guests and provide you the numbers. Most likely it won't scale to
that numbers of VIFs, given that the maptrack size increases much quicker 
(nr_vifs * 512 * nr_queues grants mapped) thus I also added the option of not
exposing "feature-persistent" if xen-netback.max_persistent_gnts module param is
set to 0. I am aware of these issues with persistent grants, but the case I had
in mind, was fewer VMs with higher throughput, which I believe to be the compromise
with persistent grants.
