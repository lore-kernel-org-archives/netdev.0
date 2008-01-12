From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Fri, 11 Jan 2008 22:03:47 -0500
Message-ID: <1200107027.4477.36.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>
	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:10515 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503AbYALDDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 22:03:52 -0500
Received: by py-out-1112.google.com with SMTP id u52so1993373pyb.10
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 19:03:51 -0800 (PST)
In-Reply-To: <4787D49E.6080906@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-01 at 18:42 -0200, Dzianis Kahanovich wrote:

> About script example:
> While I compose filter, I check flag ($TC_INDEX2MARK), tells me are patch
> applied or no. If no - I use usual "-j MARK --set-mark", else I use classid to
> change mark. All in ingress only. For example:
> tc filter add dev eth0 parent ffff: protocol ip u32 ... action ipt -j MARK 0x10
> are cname to:
> tc filter add dev eth0 parent ffff: protocol ip u32 ... flowid :10

I thought you were doing something like this (to achieve your policy):

----------
major=1
minor=12
mark=`expr $major + $minor`
#
tc qdisc add dev XXX ingress
tc filter add dev XXX parent ffff: protocol ip prio 5 \
u32 blah bleh \
flowid $major:$minor action \
ipt -j mark --set-mark $mark
---------------

> - it use less code/modules and, in many cases, may be single/main goal to
> ingress usage - pre-marking packets.

That is true and you would also have one less line in your policy; as an
example in above the line "ipt -j mark --set-mark $mark" would be
unnecessary; however, all the other lines in the policy setting _will be
necessary_. And this + the fact there are many other values/shapes the
default policy could take is essentially whats bothering me. 

In any case, scanning the current code it seems mark is no longer
considered a netfilter-only metadatum - so it may not be semantically as
obscene as i felt earlier; Can you pick something simpler for policy?
example set the mark to whatever tc_index gets set?
If you still could write the metadata action, we could use it to
override mark, tc_index etc in addition.

cheers,
jamal

