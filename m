From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Sun, 14 Sep 2014 08:02:40 -0400
Message-ID: <541583E0.7050504@oracle.com>
References: <54146A42.1050703@oracle.com> <028736E5-2648-4642-881C-25BBC6E7C848@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39711 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbaINMCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 08:02:46 -0400
In-Reply-To: <028736E5-2648-4642-881C-25BBC6E7C848@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/13/2014 11:30 PM, Raghuram Kothakota wrote:
> I have a question around bumping the sunvnet vio_version to 1.6.
> Each of the versions from 1.0, have a specific feature or behavior defined in the
> protocol, if a given version is negotiated then peers will assume the Guest
> can handle all those feature/enhancement automatically. If a given feature
> is not supported or implemented, it may be best to handle those cases gracefully.

It doesn't (and shouldn't) assume it supports any feature that isn't negotiated, and
the code I submitted does not support or negotiate receive rings, for example. It
therefore does not set the bit. The VIO protocol can negotiate TSO,
which is not supported on Linux, so it doesn't set VNET_LSO_IPV4_CAPAB. And,
as in your example, we don't want physical link state updates, so we use
PHYSLINK_UPDATE_NONE (==0).

I implemented from the VIO protocol spec and verified interoperability by testing
with pre-patched Linux (VIO v1.0) and Solaris 11.1 and 11.2.

> For example, if version 1.3 or higher is negotiated, then Guest is assumed to
> support vlan packet processing.

Nobody should *assume* VLAN support is there based on the VIO protocol version. v1.3
and higher require from the driver that there be space for a vlan header, which I have
added in the patch. I did not do anything else with VLAN processing, because this is
not a patch to add VLAN support, and nothing requires Solaris to enable it. It is no
different with respect to VLAN support than it was before the patch, meaning that if
an admin tries to use a feature that isn't supported on all the machines, it won't
work, just as it wouldn't work pre-patch to enable VLAN on Solaris and try to use it
with Linux over sunvnet. The patch is to update the VIO protocol, which is the layout
and semantics of the fields. It is not to support every feature that can be negotiated
within the protocol.

								+-DLS
