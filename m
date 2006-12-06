From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Wed, 06 Dec 2006 18:17:50 +0100
Message-ID: <4576FB3E.8000702@trash.net>
References: <20061206131807.GA2858@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34322 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936860AbWLFRRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:17:54 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061206131807.GA2858@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 04-12-2006 16:34, Patrick McHardy wrote:
> 
>>Thomas, Jamal, do you have an idea what this "old method" stuff
>>is used for? It seems it is only used during the below mentioned
>>race.
> 
> 
> Sorry for eavesdropping, but have a look at htb_classify
> starting comment. It is also used by unofficial but quite
> popular IPMARK target. 

Yes I know, I just didn't see how it could be configured to
really use that code. But while trying to explain the flow
that would always lead to tp->root != NULL in this mail, I
noticed I missed something :)

At the top of fw_change:

        if (!opt)
                return handle ? -EINVAL : 0;

which happens when adding a fw classifier without specifying any
arguments. My previous fix is still enough, but we can't remove
this of course.

