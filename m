From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol version 1.6
Date: Sun, 14 Sep 2014 10:21:20 -0700
Message-ID: <948D159A-EFAC-4ADA-94B0-2A79561A3D15@oracle.com>
References: <54146A42.1050703@oracle.com> <028736E5-2648-4642-881C-25BBC6E7C848@oracle.com> <541583E0.7050504@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32631 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaINRV1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 13:21:27 -0400
In-Reply-To: <541583E0.7050504@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following is a highlevel view of what we have in LDoms virtual network
infrastructure.

1. The vio protocol version number to introduce new messages and/or
    changes to the existing messages. 
 
    In the past there may be a case or two where the version number is
    assumed as a capability, an example is the version 1.3.

2. Flexibility to negotiate or enable individual feature/enhancement. That
    is attribute negotiation includes the ability for each peer to negotiate
    any specific feature/enhancement independently of the others. 

    An example of this are, physical link state updates(that you pointed out),
    mtu, LSO support, dring mode(TX_DRING or RX_DRING_DATA) etc.

3. Properties in MD(machine description) as way to set or enable these features
    for a Guest. This typically involves an administrative command.

    For example, an administrator can enable/disable the behavior of physical
    linkstate. The vlan-ids and mtu are also part of the administrative commands.

4. Finally the OS version(and/or patches) that is installed in a guest. 
    Without the OS/driver support, an administrator settings may not work. 
    Most of the controls revolve around the service domain, we use a new framework
    in place for administrative commands to check if the given service domain
    has the required support to enforce a specific option. In case of Guest domains,
    it's just to the Guest to enable/disable or implement a feature.

Please below for my response.

On Sep 14, 2014, at 5:02 AM, David L Stevens <david.stevens@oracle.com> wrote:

> 
> 
> On 09/13/2014 11:30 PM, Raghuram Kothakota wrote:
>> I have a question around bumping the sunvnet vio_version to 1.6.
>> Each of the versions from 1.0, have a specific feature or behavior defined in the
>> protocol, if a given version is negotiated then peers will assume the Guest
>> can handle all those feature/enhancement automatically. If a given feature
>> is not supported or implemented, it may be best to handle those cases gracefully.
> 
> It doesn't (and shouldn't) assume it supports any feature that isn't negotiated, and
> the code I submitted does not support or negotiate receive rings, for example. It
> therefore does not set the bit. The VIO protocol can negotiate TSO,
> which is not supported on Linux, so it doesn't set VNET_LSO_IPV4_CAPAB. And,
> as in your example, we don't want physical link state updates, so we use
> PHYSLINK_UPDATE_NONE (==0).
> 
> I implemented from the VIO protocol spec and verified interoperability by testing
> with pre-patched Linux (VIO v1.0) and Solaris 11.1 and 11.2.

Thanks, if you have verified these cases then it addresses my comment.
In the code, it will be good to explicitly set the attribute such as "plnk_updt" to
the PHYSLINK_UPDATE_NONE and probably add a comment on top of
it would be even better. The same could be done for the other attribute as
well.

> 
>> For example, if version 1.3 or higher is negotiated, then Guest is assumed to
>> support vlan packet processing.
> 
> Nobody should *assume* VLAN support is there based on the VIO protocol version. v1.3
> and higher require from the driver that there be space for a vlan header, which I have
> added in the patch. I did not do anything else with VLAN processing, because this is
> not a patch to add VLAN support, and nothing requires Solaris to enable it. It is no
> different with respect to VLAN support than it was before the patch, meaning that if
> an admin tries to use a feature that isn't supported on all the machines, it won't
> work, just as it wouldn't work pre-patch to enable VLAN on Solaris and try to use it
> with Linux over sunvnet. The patch is to update the VIO protocol, which is the layout
> and semantics of the fields. It is not to support every feature that can be negotiated
> within the protocol.

That's fine. My point was about  we have verified each of these
minor version specifics are thought and the behavior is understood.

-Raghuram


> 
> 								+-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
