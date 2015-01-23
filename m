From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 11:24:21 +0100
Message-ID: <20150123102421.GB2065@nanopsycho.orion>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:60019 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbbAWKYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 05:24:25 -0500
Received: by mail-wi0-f182.google.com with SMTP id n3so1726741wiv.3
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 02:24:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150123101019.GF25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 11:10:19AM CET, tgraf@suug.ch wrote:
>On 01/22/15 at 10:44am, Jamal Hadi Salim wrote:
>> On 01/22/15 10:37, Thomas Graf wrote:
>> >On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
>> 
>> >>So if i am a vendor with my own driver, I can expose whatever i want.
>> >
>> >No. We will reject any driver change attempting to do so on this
>> >list.
>> >
>> 
>> Vendor provides a driver that exposes a discoverable interface
>> (capabilities exposure that is facilitated).
>> They dont need it to be part of the mainstream kernel.
>> And they dont need any of your definitions.
>
>An out of tree driver always had the possibility to register its own
>Generic Netlink protocol and do exactly what you describe. The same
>driver could also register as { xt, cls, act } module and export direct
>hardware access to userspace through tc and iptables. The driver could
>even register its own netfilter hook. You can abuse pretty much any
>interface that has some form of registration mechansim from an out of
>tree driver. We can't really control that.
>
>I think we agree that the value of this model is that tools like nft,
>OVS, SnabbSwitch, tc, [you name it] can use it to program the hardware
>in a very generic manner from user space without requiring to move all
>of that complexity to the kernel. In the very same way as the team
>device exports most of the complexity to user space. Or for the same
>reason routing protocol implementations were kept out of the kernel.


I think that comparing this to team or routing userspace is not
correct. The reason is that team and routing has single api to kernel.
However in this case userspace has to use multiple APIs.

For example OVS. It would have to use existing OVS gennetlink iface + this
new flow netlink iface for flow offloads. For all others, this is the same.
Multiple apis for the same thing (does not matter if it is implemented
in hw or sw) does not seem right to me.


>
>If a vendor exposes capabilities in a form that is not understood by
>the well known tools it has zero value because the capabilities can't
>be used. Any tool that would depend on such vendor specific bits that
>are exported by out of tree drivers might as well use the existing
>vendor SDKs which will always provide some additional functionality
>because it doesn't have to compromise.
>
