From: Patrick McHardy <kaber@trash.net>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 09:05:47 +0100
Message-ID: <478DBADB.1080200@trash.net>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net> <20080116080259.GB1638@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63334 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbYAPIGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 03:06:11 -0500
In-Reply-To: <20080116080259.GB1638@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Jan 16, 2008 at 06:02:00AM +0100, Patrick McHardy wrote:
> ...
>> This would need support from the qdiscs to do it properly. Looks
>> non-trivial for HTB/HFSC/CBQ, but the others shouldn't be that hard.
> 
> Yes. At first I've thought this would need quite a lot of work, but
> it seems, there could be probably used something very simple too,
> like e.g. a 'dummy' sched switcher, which after replacing as a root
> the old qdisc and knowing the pointer to the new one could simply
> call for dequeing the old one and the new one for everything else.
> Then, after completely dequeuing it would call destroy for the old
> qdisc and probably switch itself with the new one as a root. If this
> new one were created temporarily e.g. on a dummyX dev, and the switch
> qdisc added to dummyY (as a temporary holder) with ethX and dummyX as
> parameters, it seems this could be done without any API changes.
> (But, of course, something more sophisticated should be even better.)


Yes, thats one possibility (without the dummy device though please).
But I wonder what this would actually be useful for. I don't think
replacing the root qdisc by a different type is a common scenario,
for the same type you can simply use "tc qdisc change", "tc class
change" and "tc class replace".

Badalian, what are you actually doing?
