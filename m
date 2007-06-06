From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 18:32:50 +0200
Message-ID: <4666E1B2.1070109@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain> <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com> <46669FA0.3030405@trash.net> <m1d509umtp.fsf@ebiederm.dsl.xmission.com> <4666D426.2070606@trash.net> <20070606155634.GA15067@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57532 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbXFFQdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:33:19 -0400
In-Reply-To: <20070606155634.GA15067@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
>>						 I just suggested to
>>Pavel to create only a single device per newlink operation and binding
>>them later,
> 
> 
> I see some logical inconsistency here.
> 
> Look, the second end is supposed to be in another namespace.
> It will have identity, which cannot be expressed in any way in namespace,
> which is allowed to create the pair: name, ifindex - nothing
> is shared between namespaces.


Good point, I didn't think of that. Is there a version of this patch
that already uses different namespaces so I can look at it?

Are network namespace completely seperated or is there some hierarchy
with all lower namespaces visible above or something like that?

> Moreover, do not forget we have two netlink spaces as well.
> Events happening in one namespace are reported only inside that namespace.
> 
> Actually, the only self-consistent solution, which I see right now
> (sorry, did not think that much) is to create the whole pair as
> one operation; required parameters (name of partner, identity of namespace)
> can be passed as attributes. I guess IFLA_PARTNER approach suggests
> the same thing, right?


I imagined it more as a bind operation, pretty similar to enslave, so
it would only contain an ifindex, no parameters. But as you say that
doesn't work, so I guess we'd have to nest an entire ifinfomsg + the
attributes for the partner device under it .. not exactly pretty.

> As response to this action two replies are generated: one RTM_NEWLINK
> for one end of device with the whole desciption of partnet
> is broadcasted inside this namespace, another RTM_NETLINK with index/name
> of partner device is broadcasted inside the second namespace
> (and, probably, some attributes, which must be hidden inside namespace,
> f.e. identity of main device is suppressed). 


The identity of the main device has no meaning within a different
namespace, but are there other reasons for hiding it?
