From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: tcpdump's capture filter: "vlan" doesn't match
Date: Fri, 17 Oct 2014 17:48:50 +0200
Message-ID: <54413A62.9060806@redhat.com>
References: <DUB123-W23D5ECAD4869F9A799E1F6EDAA0@phx.gbl>,<543F616C.5040801@redhat.com> <DUB123-W25C5DA9BEDC92CD2524B68EDAB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Jesse Gross <jesse@nicira.com>,
	Michael Richardson <mcr@sandelman.ca>,
	Ani Sinha <ani@aristanetworks.com>
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286AbaJQPtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2014 11:49:20 -0400
In-Reply-To: <DUB123-W25C5DA9BEDC92CD2524B68EDAB0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2014 01:25 AM, Lukas Tribus wrote:
>>> Isn't disabling rx-vlan-offloading supposed to remedy those problems?
>>
>> There were some discussions on this in the past e.g. [1]. We have
>> SKF_AD_VLAN_TAG and SKF_AD_VLAN_TAG_PRESENT for the BPF filter on
>> this, but libpcap is currently not making use of any of them.
>>
>> [1] http://thread.gmane.org/gmane.linux.network/247947
>
> Thanks for the link. I see the situation is unfortunate and although those
> new BPF filters in the kernel may fix the actual filtering problem, one
> thing seems to remain impossible: disabling all this kernel magic and
> passing the frame as-is to libpcap without interception (avoiding any
> kind of artificial header reconstruction).
>
> How is the situation with netsniff-ng anyway? Does it use vlan BPF filter
> in the kernel?

So in netsniff-ng we don't do obscure header reconstruction as it
hurts performance and it can result in incorrect reconstruction cases.

You however can define a bpf_asm program (e.g. tools/net/ in kernel
tree) and use instruction overloading for the vlan case from there.
Thus, you're not tied to the libpcap compiler which misses this.

For more details, I refer you to Documentation/networking/filter.txt .
