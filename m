From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 08:59:19 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143B0E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:61968 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030448AbWD1P7a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 11:59:30 -0400
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Apr 27, 2006 at 02:12:09PM -0700, Caitlin Bestler
> (caitlinb@broadcom.com) wrote:
>> So the real issue is when there is an intelligent device that uses
>> hardware packet classification to place the packet in the correct
>> ring. We don't want to bypass packet filtering, but it would be
>> terribly wasteful to reclassify the packet.
>> Intelligent NICs will have packet classification capabilities to
>> support RDMA and iSCSI. Those capabilities should be available to
>> benefit SOCK_STREAM and SOCK_DGRAM users as well without it being a
>> choice of either turning all stack control over to the NIC or
>> ignorign all NIC capabilities beyound pretending to be a dumb
>> Ethernet NIC. 
> 
> Btw, how is it supposed to work without header split capabale
> hardware?

Hardware that can classify packets is obviously capable of doing
header data separation, but that does not mean that it has to do so.

If the host wants header data separation it's real value is that when
packets arrive in order that fewer distinct copies are required to
move the data to the user buffer (because separated data can
be placed back-to-back in a data-only ring). But that's an optimization,
it's not needed to make the idea worth doing, or even necessarily
in the first implementation.

