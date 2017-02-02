From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Thu, 02 Feb 2017 06:33:21 -0800
Message-ID: <58934331.1090106@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <20170202012301.GA74213@ast-mbp.thefacebook.com> <5892CA81.1020804@cumulusnetworks.com> <20170201230614.0b2a2163@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33262 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBOdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 09:33:23 -0500
Received: by mail-pf0-f176.google.com with SMTP id y143so5794671pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 06:33:23 -0800 (PST)
In-Reply-To: <20170201230614.0b2a2163@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/17, 11:06 PM, Stephen Hemminger wrote:
> On Wed, 01 Feb 2017 21:58:25 -0800
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> On 2/1/17, 5:23 PM, Alexei Starovoitov wrote:
>>> On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:
>>>  
>>
[snip]

>>> I think most swith asics can do other tunnels too,
>>> so can this vlan->vxlan 1 to 1 be generalized to cover different
>>> types of tunnels that can be configured on the switch?  
>>
>> yes, it can be. Hence i have kept the tunnel info netlink attribute generic. similar to how LWT provides
>> various encaps at the L3 routing layer, this can provide such function at the L2 bridge layer. But, to keep it relatively lite I use the
>> already existing dst_metadata infra to bridge vlan to vxlan (Which is already done in the case of vxlan collect metadata mode.
>> I simply extend it to cover the bridge case).
>>
>> thanks,
> I wonder if this is a case for a new driver (with same subset of bridge API). You probably
> don't want all the baggage of STP, netfilter, VLAN filtering, etc when doing VXLAN VNI bridging.

We do want stp, netfilter, VLAN filtering, igmp snooping on the same bridge. In-fact this vlan-to-tunnel incremental feature I add here is only
available to the vlan filtering bridge.

It is in our best interest to make or keep the bridge driver suitable for all architectures. You have seen the bridge perf fixes from nikolay
recently, all those are towards the same effort. Nikolay has had a bunch of cleanup ideas and has been contributing patches to that effect.
 I think we should work on cleaning up and fixing the current bridge driver instead of introducing a new one. The bridge driver has a nice api which has been working great for various deployments...(like i mention, also for the hardware offload case).

If you have any performance numbers or data from other architectures, we would be happy to take a look and see what we can do more.
