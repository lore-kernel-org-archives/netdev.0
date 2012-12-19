From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 09:13:10 -0500
Message-ID: <50D1CB76.50202@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com> <20121219101006.7086faef@pixies.home.jungo.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab2LSONR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 09:13:17 -0500
In-Reply-To: <20121219101006.7086faef@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 03:10 AM, Shmulik Ladkani wrote:
> Thanks Vlad,
>
> On Tue, 18 Dec 2012 14:00:51 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>> A single vlan may also be designated as untagged.  Any untagged traffic
>> recieved by the port will be assigned to this vlan.
>
> Why the "untagged vlan" is per-bridge global?
> Usually, 802.1q switches define the PVID (port's VID) which controls
> the value of VID, in case ingress frame is either untagged or
> priority-tagged (per port configuration).
> This gives greater flexibility.

It's not.  There is a per port untagged pointer where you can designate 
which VLAN is untagged/native on a port.  The bride interface itself
can also function as a port, so it gets its own untagged pointer so
it can behave similar to port.

>
>> Any traffic exiting
>> the port with a VID matching the untagged vlan will exit untagged (the
>> bridge will strip the vlan header).  This is similar to "Native Vlan" support
>> available in most switches.
>
> 802.1q switches usually allow conifguring per-vlan, per-port
> tagged/untagged egress policy: each vid has its port membership map and
> an accompanying port egress-policy map.
> This gives great flexibility defining all sorts of configurations.

Right, and that's what's provided here.
  * Each VLAN has port membership map (net_bridge_vlan.portgroup).
  * Each port has a list of vlans configured as well 
(net_port_vlan.vlan_list).
  * Each port also has a single vlan that can be untagged 
(net_bridge_port.untagged).
  * The bridge also has a single untagged vlan (net_bridge.untagged)

The limitation (in switches as well) is that only a single VLAN
may be untagged on any 1 port.  If you have more then 1, you don't know
which VLAN the untagged traffic belongs to.

>
> Personally, I'd prefer a fully flexible vlan bridge allowing all sorts
> of configurations (as available in 802.1q switches).
>
> What's the reason limiting such configurations?

So, what do you see that's missing?

-vlad

>
> Regards,
> Shmulik
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
