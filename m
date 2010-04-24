From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile (was iovnl)
Date: Sat, 24 Apr 2010 07:37:57 -0700
Message-ID: <C7F85055.2B535%scofeldm@cisco.com>
References: <20100424022242.GF3843@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <arnd@arndb.de>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:58711 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab0DXOiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 10:38:03 -0400
In-Reply-To: <20100424022242.GF3843@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/10 7:22 PM, "Chris Wright" <chrisw@redhat.com> wrote:

>> I took some liberties and s/SR-IOV/IOV in the code comments around the
>> ndo_set_vf_* cmds as they can apply to both SR-IOV and non-SR-IOV adapters,
>> as long as there is a PF:VF parent:child relationship.
> 
> For enic case, which do you expect to use for net_dev and VF index?  Would
> this be VF + index== 0 (meaning the degenerate case you described last
> time where PF==VF)?

Yes, for this enic PF==VF, but that's a short term situation.  It's a small
matter of programming (in firmware) to turn enic into the more general case.
But I want to focus on getting port-profile support in first, with the
current enic+firmware.

>> A port-profile is used to configure/enable the network port backing the VF,
>> not
>> to configure the host-facing side of the VF.
> 
> How shall we do the lldpad case?

Same as before with iovnl.  The sender of RTM_SETLINK msg (say libvirt)
needs to send with mcast group RTMGRP_LINK and listener (say lldpad) needs
to listen on that mcast group.  This way, both kernel and user-space get the
msg.

>> + if (tb[IFLA_VF_PORT_PROFILE]) {
>> +  struct ifla_vf_port_profile *ivp;
>> +  ivp = nla_data(tb[IFLA_VF_PORT_PROFILE]);
>> +  err = -EOPNOTSUPP;
>> +  if (ops->ndo_set_vf_port_profile)
>> +   ivp->port_profile[sizeof(ivp->port_profile)-1] = 0;
>> +   ivp->host_uuid[sizeof(ivp->host_uuid)-1] = 0;
>> +   ivp->client_uuid[sizeof(ivp->client_uuid)-1] = 0;
>> +   ivp->client_name[sizeof(ivp->client_name)-1] = 0;
> 
> Seems a little unusual to modify the buffer, add a kernel internal structure
> that can be passed to ndo callback (where buffer lens can be knonw)?

Ok, let me see what can be done here.

-scott

