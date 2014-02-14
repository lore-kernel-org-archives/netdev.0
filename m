From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: 802.3ad: make aggregator_identifier bond-private
Date: Fri, 14 Feb 2014 13:16:19 -0800
Message-ID: <21312.1392412579@death.nxdomain>
References: <20140214171350.GC11688@midget.suse.cz> <20140214191243.GA3173@localhost.localdomain> <20140214205147.GA1798@midget.suse.cz>
Cc: Flavio Leitner <fbl@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47757 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbaBNVQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:16:25 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 14 Feb 2014 14:16:25 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id ED2D819D804C
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:16:21 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1EJDkQL54329470
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 20:13:46 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1ELJj1F028747
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:19:45 -0700
In-reply-to: <20140214205147.GA1798@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>On Fri, Feb 14, 2014 at 05:12:43PM -0200, Flavio Leitner wrote:
>> On Fri, Feb 14, 2014 at 06:13:50PM +0100, Jiri Bohac wrote:
>> > Fix this by making aggregator_identifier private to the bond.
>> 
>> I don't see how you fix the duplicate agg id with this patch because
>> you initialize for each bond to 0, then use the same algo further on.
>> So, what is changing?
>
>My understanding is that the aggregator identifier is used
>internally by the bond and never appears anywhere in the LACP
>traffic.
>
>So having duplicate aggregator ids between two bonds on the same
>machine does not matter. But it is a problem if two aggregators
>in the same bond share the same id.
>
>Is my understanding wrong?

	Your understanding is correct.

>> Actually, aggregator_identifier is a global variable to make sure the
>> counter is always increasing for new bonds.  So, the fix would be to
>> not reset it to zero, isn't it?
>
>I was considering this fix, but my concern was that the variable
>(u16) would overflow sooner than it does now. It would take 2^16
>enslavings on the machine, while with my patch you need 2^16
>enslavings on a single bond.
>
>Hypothetically, a rogue NET_ADMIN in one net namespace may cause
>this overflow to break a bond in another nemespace.
>
>Maybe I'm being paranoid? ;)

	Personally, for ease of reading debug messages, I would prefer
the globally unique ID (or a patch to update the pr_debugs to add the
bond name).  From a technical point of view either way will function
correctly.  I'm not too worried about the overflow of the ID.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
