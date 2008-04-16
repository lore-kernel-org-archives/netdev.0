From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH]: net/bonding: Enable to change device type before enslaving
Date: Wed, 16 Apr 2008 12:27:46 -0700
Message-ID: <11141.1208374066@death>
References: <47FE2DBF.7080803@voltaire.com> <21771.1207860504@death> <48021410.5040806@voltaire.com>
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43517 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbYDPT1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 15:27:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3GJTsos011547
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 15:29:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3GJRmhE389374
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 15:27:48 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3GJRm1B027225
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 15:27:48 -0400
In-reply-to: <48021410.5040806@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moni Shoua <monis@voltaire.com> wrote:

>> 	Does this mean that the automatic selection on first enslavement
>> is no longer needed, and all setting of the type for IB devices must
>> occur prior to first enslavement?
>> 
>> 	Or is this more of a special case for some devices, and the
>> automatic selection is still correct for most cases?
>> 
>
>I think that the later is closer to the truth. 
>The goal is to modify the bonding module to work with IPoIB slaves but
>with as small as possible changes to what already exists.
>
>In details, the bonding net device device gets its type by
>ether_setup(), which runs for all types of slaves and I don't see a way
>to change that.  However, bonding master for IPoIB slaves requires a
>different device type setting before it comes up for some OSs (redhat 4
>for instance). On other OSs I don't see the problem and I guess that
>this is because master becomes up only after it has slaves.

	If I'm reading the above correctly, then this type selection is
only needed for Red Hat 4 (or, really, versions of bonding prior to when
the bonding master started to set its carrier state based upon the state
of the slaves), correct?

	If that's the case, then is this patch is fixing a problem that
doesn't exist in the mainline?  If this isn't a problem with the current
driver (where "current" here seems to be bonding 3.0.3 and later, which
is about two years old), I don't see why it should go into the mainline.

	Am I misunderstanding something?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
