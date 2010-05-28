From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V9 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 27 May 2010 20:24:30 -0700
Message-ID: <C824857E.35C36%scofeldm@cisco.com>
References: <4BF54616.1020508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>, <arnd@arndb.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42593 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab0E1DYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 23:24:33 -0400
In-Reply-To: <4BF54616.1020508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/20/10 7:24 AM, "Patrick McHardy" <kaber@trash.net> wrote:

> Scott Feldman wrote:
>> +static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
>> +{
>> + struct nlattr *vf_ports;
>> + struct nlattr *vf_port;
>> + int vf;
>> + int err;
>> +
>> + vf_ports = nla_nest_start(skb, IFLA_VF_PORTS);
>> + if (!vf_ports)
>> +  return -EMSGSIZE;
>> +
>> + for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
>> +  vf_port = nla_nest_start(skb, IFLA_VF_PORT);
>> +  if (!vf_port) {
>> +   nla_nest_cancel(skb, vf_ports);
>> +   return -EMSGSIZE;
>> +  }
>> +  NLA_PUT_U32(skb, IFLA_PORT_VF, vf);
>> +  err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
>> +  if (err) {
>> +nla_put_failure:
>> +   nla_nest_cancel(skb, vf_port);
>> +   continue;
> 
> Are you sure you want to continue here? During a full dump
> this means that the last VF port fitting in the skb will most
> likely be incomplete since the higher layer code won't
> notice that the size was exceeded and the entry should be
> dumped into another skb.

Drats, that's a bug.  I'll get that fixed.  Thanks Patrick for catching it.

-scott

