From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 6 Jun 2007 19:56:34 +0400
Message-ID: <20070606155634.GA15067@ms2.inr.ac.ru>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain> <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com> <46669FA0.3030405@trash.net> <m1d509umtp.fsf@ebiederm.dsl.xmission.com> <4666D426.2070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:37436 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751098AbXFFQOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 12:14:01 -0400
Content-Disposition: inline
In-Reply-To: <4666D426.2070606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> 						 I just suggested to
> Pavel to create only a single device per newlink operation and binding
> them later,

I see some logical inconsistency here.

Look, the second end is supposed to be in another namespace.
It will have identity, which cannot be expressed in any way in namespace,
which is allowed to create the pair: name, ifindex - nothing
is shared between namespaces.

Moreover, do not forget we have two netlink spaces as well.
Events happening in one namespace are reported only inside that namespace.

Actually, the only self-consistent solution, which I see right now
(sorry, did not think that much) is to create the whole pair as
one operation; required parameters (name of partner, identity of namespace)
can be passed as attributes. I guess IFLA_PARTNER approach suggests
the same thing, right?

As response to this action two replies are generated: one RTM_NEWLINK
for one end of device with the whole desciption of partnet
is broadcasted inside this namespace, another RTM_NETLINK with index/name
of partner device is broadcasted inside the second namespace
(and, probably, some attributes, which must be hidden inside namespace,
f.e. identity of main device is suppressed). 

Alexey


