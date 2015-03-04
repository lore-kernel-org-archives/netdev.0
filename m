From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/2] neigh: Factor out ___neigh_lookup_noref
Date: Wed, 04 Mar 2015 09:58:28 -0600
Message-ID: <87sidkoiu3.fsf@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87bnk9y8wb.fsf_-_@x220.int.ebiederm.org>
	<20150304145331.GA1551@gospo>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40728 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758509AbbCDQCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 11:02:04 -0500
In-Reply-To: <20150304145331.GA1551@gospo> (Andy Gospodarek's message of "Wed,
	4 Mar 2015 09:53:31 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <gospo@cumulusnetworks.com> writes:

> On Tue, Mar 03, 2015 at 05:10:44PM -0600, Eric W. Biederman wrote:
>> 
>> While looking at the mpls code I found myself writing yet another
>> version of neigh_lookup_noref.  We currently have __ipv4_lookup_noref
>> and __ipv6_lookup_noref.
>> 
>> So to make my work a little easier and to make it a smidge easier to
>> verify/maintain the mpls code in the future I stopped and wrote
>> ___neigh_lookup_noref.  Then I rewote __ipv4_lookup_noref and
>> __ipv6_lookup_noref in terms of this new function.  I tested my new
>> version by verifying that the same code is generated in
>> ip_finish_output2 and ip6_finish_output2 where these functions are
>> inlined.
>> 
>> To get to ___neigh_lookup_noref I added a new neighbour cache table
>> function key_eq.  So that the static size of the key would be
>> available.
>> 
>> I also added __neigh_lookup_noref for people who want to to lookup
>> a neighbour table entry quickly but don't know which neibhgour table
>> they are going to look up.
>
> While I understand your intent here, you do really need to know which
> neighbour table being used in order to do the look-up with your new
> function, so this changelog isn't quite accurate.  I know Dave has
> already accepted this patch, but it did not appear in the tree I just
> updated, so hopefully there is time to fix this if you agree with me.

Currently __ipv4_lookup_noref and __ipv6_lookup_noref hard code the
table.  __neigh_lookup_noref works without needing to hard code the
neighbour table.  The neighbour table being a variable in the code and
not a hard coded value is what I was referring to above when I said you
don't need to know your neighbour table.  That is you still need a
neighbour table it just doesn't need to be hard coded.

Eric
