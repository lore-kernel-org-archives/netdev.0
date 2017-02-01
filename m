From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/5] bridge: per vlan dst_metadata support
Date: Wed, 01 Feb 2017 11:12:22 -0800
Message-ID: <58923316.60009@cumulusnetworks.com>
References: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com> <20170131084134.405043f8@xeon-e3> <5890F6E7.7040402@cumulusnetworks.com> <20170201083523.0b1bdac6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33129 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdBATMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 14:12:25 -0500
Received: by mail-pf0-f181.google.com with SMTP id y143so120480406pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 11:12:24 -0800 (PST)
In-Reply-To: <20170201083523.0b1bdac6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/17, 8:35 AM, Stephen Hemminger wrote:
> On Tue, 31 Jan 2017 12:43:19 -0800
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> On 1/31/17, 8:41 AM, Stephen Hemminger wrote:

[snip]

>> But, this is just discouraging people from using the bridge driver. sorry, but i think it is a bit too late for that now :) 
> It is time for a new driver (like team was for bonding). That does less in the kernel,
> and has a cleaner API for extension. Then the actual bridge forwarding path can be reduced
> down to something more manageable. 
sure. But, this patch series is an incremental extension to the already existing vlan filtering feature
in the bridge driver.

>> A few things:
>> - Like I have said before, bridge driver vlan filtering and forwarding database has been
>> ideal to offload to switch asics. We have many industry standard bridging
>> networking features deployed using the bridge driver...even the vxlan bridging gateway
>> I mention in the deployment section above (this patch series just helps with scaling those deployments).
>> When bridge driver has all it takes to be deployed on a data center switch today, I am not understanding
>> the argument on saving it from newer features. why not enable bridge for newer features when people are using it ?
>>
>> - vlan to tunnel-id (or vlan to vxlan id) mapping is not a hack. It is supported on every data center switch
>> that supports l2 gateway functions today (google will give a few hits).
>>
>> - dst_metadata propagation is also not a hack. It is a generic infrastructure provided by the kernel
>> that any subsystem can use...and is already in use in various parts in the kernel today.
>>
>> - We heavily use bridge driver forwarding database for our l2 deployments similar to the routing fib.
>> With routing protocols like bgp being used as control plane for l2 overlays
>>  https://tools.ietf.org/html/draft-ietf-bess-evpn-overlay-07, bgp implementations like quagga will also
>> now start looking at the bridge forwarding database.
>>
>> - this patchset enables a feature which is off by default, so i am not sure how it is adding additional
>> complexity to the bridge driver.
> The Openstack and Docker architectures have lots of small bridges. These are really endpoint vswitches
> having something lighter would help them.

the feature in this series is disabled by default and is an extension to the existing vlan filtering code.
It is only enabled if CONFIG_BRIDGE_VLAN_FILTERING is enabled. If you did like me to add an additional
CONFIG_*, I can do so.

Openstack and Docker architectures don't have to enable vlan filtering,  it is disabled by default.
seems like we need a new bridge driver that is lighter for these architectures....because the current
one already supports vlan filtering and stp and igmp snooping for data center architectures.
shutting the bridge driver for any incremental features for the data center would need more reasons
 than this.
>
> I admit my bias. like Radia Perlman, it seems people keep reinventing L2 features to implement features
> that belong in L3. Coddling along old broken applications that run on L2.
>
>
l2 overlays are not uncommon in data center deployments ...and its not us who is re-inventing this.
As you know we would love to move the industry and data center architectures to pure l3...,
but it is not time for that yet.

thanks,
Roopa
