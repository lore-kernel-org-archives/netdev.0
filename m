From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: add mark mode
Date: Fri, 01 May 2009 13:31:23 -0700
Message-ID: <5384.1241209883@death.nxdomain.ibm.com>
References: <20090501173916.GA6608@gospo.rdu.redhat.com> <20090501193403.GA5840@hmsreliant.think-freely.org> <501.1241207536@death.nxdomain.ibm.com> <20090501200940.GB5840@hmsreliant.think-freely.org>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:38334 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbZEAUbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 16:31:18 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n41KKOcM015469
	for <netdev@vger.kernel.org>; Fri, 1 May 2009 16:20:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n41KVHWA153970
	for <netdev@vger.kernel.org>; Fri, 1 May 2009 16:31:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n41KVHev031166
	for <netdev@vger.kernel.org>; Fri, 1 May 2009 16:31:17 -0400
In-reply-to: <20090501200940.GB5840@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>> 	If I'm not misunderstanding the purpose of the mode, I think
>> it's etherchannel compatible (meaning that the switch has to be
>> configured), so I'm not sure why there would ever be a need to flood
>> packets to all ports.
>> 
>It entirely possible that there may be no need to flood frames, I was just
>asking the question.  And while it is possible that this might be etherchannel
>compatible (in fact I agree, it does look compatible), I can see uses for it
>beyond that (active-backup with traffic-class load balancing for example).

	For that last comment (active-backup), are you thinking in terms
of N active slaves and one backup?

>> 	I think this would be generally be better a special hash policy,
>> in which case both the etherchannel (balance-xor) and 802.3ad modes
>> could take advantage of it.  I'd hazard to guess that Andy thought about
>> that, too, so what was the impediment?
>
>I honestly don't know, although I will say that making a special hash mode for
>balance-xor seems a bit odd, since the implication there would be that output
>port was no longer chosen by an xor operation.

	Well, there are already three different hash algorithms that can
be selected, and if the only thing stopping this functionality as some
type of different slave selection gizmo is terminology, then I'm happy
to change the name of "xmit_hash_policy" to simply "xmit_policy" (in a
backwards compatible manner, of course) and slap this in as a new
policy.  Yah, balance-xor has "xor" in the name, but that can either be
documented around or, again, aliased as "balance-policy" or something.

	I see no reason the terminology should stand in the way of
setting things up The Right Way (which, in this discussion, revolves
around this type of new slave selection stuff working for the largest
reasonable set of modes, here, etherchannel and 802.3ad).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
