From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Mon, 10 May 2010 11:56:39 -0700
Message-ID: <C80DA4F7.2FBCF%scofeldm@cisco.com>
References: <loom.20100510T172617-53@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: Stefan Berger <stefanb@us.ibm.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:22455 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab0EJS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 14:56:41 -0400
In-Reply-To: <loom.20100510T172617-53@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/10 8:37 AM, "Stefan Berger" <stefanb@us.ibm.com> wrote:

> Arnd Bergmann <arnd <at> arndb.de> writes:
> 
> [...]
> 
>> + if (tb[IFLA_VIRTIF]) {
>> +  struct ifla_virtif_port_profile *ivp;
>> +  struct nlattr *virtif[IFLA_VIRTIF_MAX+1];
>> +  u32 vf;
>> +
>> +  err = nla_parse_nested(virtif, IFLA_VIRTIF_MAX,
>> +           tb[IFLA_VIRTIF], ifla_virtif_policy);
>> +  if (err < 0)
>> +   return err;
>> +
>> +  if (!virtif[IFLA_VIRTIF_VF] || !virtif[IFLA_VIRTIF_PORT_PROFILE])
>> +   goto novirtif; /* IFLA_VIRTIF may be directed at user space */
> 
> 
> In what case would the IFLA_VIRTIF_PORT_PROFILE be provided? Would libvirt for
> example need to be aware of whether the Ethernet device can handle the setup
> protocol via its firmware and in this case provide the port profile parameter
> and in other cases provide other parameters? Certainly the user or upper layer
> management software would have to know it when creating the domain XML and in
> fact different types of parameters were needed.

> Obviously we should have one
> common set of (XML) parameters that go into the netlink message and that can
> be handled by the kernel driver if the firmware knows how to handle it or by
> LLDPAD. 

With Arnd's latest additions, we have a single netlink msg, but the
parameter sets are disjoint between VDP/CDCP and what we need for the kernel
driver.  So that means the sender (libvirt in this case) needs to know about
both setups to send a single netlink msg.  An alternative is a have two
netlink msgs, one for each setup.  That still requires the sender to know
about two setups.  

> Libvirt would send the parameters via netlink message to trigger the
> setup protocol and the message may be received by kernel and LLDPAD.
 
That was the original idea by having libvirt send the netlink msg using
multicast.

