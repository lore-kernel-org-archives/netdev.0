From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 13:22:19 +0200
Message-ID: <49F04F6B.7010709@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> 	<alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr> 	<49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Salatiel Filho <salatiel.filho@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47519 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbZDWLW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 07:22:26 -0400
In-Reply-To: <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salatiel Filho wrote:
> On Thu, Apr 23, 2009 at 07:28, Patrick McHardy <kaber@trash.net> wrote:
>> I'm aware of those claims, but not of the details. If this is true,
>> people should raise those issues and help resolve them. I wouldn't
>> hold my breath waiting for IMQ to get fixed.
>>
> 
> I would love to see a way to change where IFB hooks [if "hook" is the
> right term ], till now i dont think i am able to hook it after nat in
> prerouting and before nat in postrouting. Is there a way to do this ?
> What i basically do with IMQ is:
> 
> 
>                          eth0 [192.168.0.0/24]
> ppp0   <---->       eth1 [192.168.1.0/24]
>                          eth2 [192.168.2.0/24]
> 
> Using imq i can shape upload on ppp0 [postrouting] while still having
> the internal private ips from the hosts, and i can shape download in
> ppp0 [prerouting] after get the correct nat'ed addresses.
> 
> Is there a way to achieve this in IFB ? in a simple way ... :)

Currently not, the conntrack association is done at a later point.
We could add a classifier or TC action that performs the lookup
during ingress classification.

Alternatively classifiers using conntrack information (like cls_flow)
could perform the lookup directly, but that would probably get a bit
ugly since some validation needs to be performed previously and it
would add a module dependency on conntrack.

