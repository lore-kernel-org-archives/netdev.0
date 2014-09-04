From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] core: Untag packets after rx_handler has run.
Date: Thu, 04 Sep 2014 17:01:12 -0400
Message-ID: <5408D318.4020009@redhat.com>
References: <1409856043-21840-1-git-send-email-vyasevic@redhat.com> <20140904190524.GA1938@nanopsycho.lan> <5408BD7C.7030805@gmail.com> <20140904204314.GA16612@its-macbook-pro.plumgrid.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	Florian Zumbiehl <florz@florz.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140AbaIDVBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 17:01:32 -0400
In-Reply-To: <20140904204314.GA16612@its-macbook-pro.plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 04:43 PM, Alexei Starovoitov wrote:
> On Thu, Sep 04, 2014 at 03:29:00PM -0400, Vlad Yasevich wrote:
>>> nack. This will definitelly break several stacked setups.
>>
>> Which ones?  The only thing I can see that would behave differently
>> is something like:
>>
>>     vlan0      bridge0
>>      |           |
>>      +-------- eth0
>>
>> In this case, the old code would give an untagged packet to the bridge
>> and the new code would give a tagged packet.
>>
>> This set-up is a bit ambiguous.  Remove the vlan, and bridge gets a tagged
>> traffic even though the vlan has no relationship to the bridge.
>>
>> I've tested a couple of different stacked setups and they all seem to work.
> 
> 2nd nack.
> It will break user space, including our setup that has:
>  vlanX     OVS
>    |        |
>    +------ eth0
> 
> vlan device has IP assigned and all tagged traffic goes through the stack
> and into control plane process. ovs datapath keeps managing eth0 with
> all other vlans.
> 

Did you specially configure OVS to pass the traffic up the stack?  I see
OVS will only pass LOOPBACK packets.  All others it seems to consume.

Can the same be accomplished with a tagged internal port?

The reason I am asking, is I am trying to figure out if this is
a valid config.  It seems very hard to get right and seems to work almost
by accident at times.  For example, in the bridge scenario I described.
vlan and bridge have to share a mac address for that work.

-vlad
