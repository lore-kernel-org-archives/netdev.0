From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/2] virtio_net: add ethtool support for set
 and get of settings
Date: Wed, 3 Feb 2016 10:19:04 +0100
Message-ID: <56B1C608.1040805@cumulusnetworks.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33428 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcBCJTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 04:19:07 -0500
Received: by mail-wm0-f52.google.com with SMTP id l66so153800968wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 01:19:06 -0800 (PST)
In-Reply-To: <1454468677-12280-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 04:04 AM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch allows the user to set and retrieve speed and duplex of the
> virtio_net device via ethtool. Having this functionality is very helpful
> for simulating different environments and also enables the virtio_net
> device to participate in operations where proper speed and duplex are
> required (e.g. currently bonding lacp mode requires full duplex). Custom
> speed and duplex are not allowed, the user-supplied settings are validated
> before applying.
> 
> Example:
> $ ethtool eth1
> Settings for eth1:
> ...
> 	Speed: Unknown!
> 	Duplex: Unknown! (255)
> $ ethtool -s eth1 speed 1000 duplex full
> $ ethtool eth1
> Settings for eth1:
> ...
> 	Speed: 1000Mb/s
> 	Duplex: Full
> 
> Based on a patch by Roopa Prabhu.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: use the new ethtool speed/duplex validation functions and allow half
> duplex to be set
> v3: return error if the user tries to change anything besides speed/duplex
> as per Michael's comment
> We have to zero-out advertising as it gets set automatically by ethtool if
> setting speed and duplex together.
> v4: Set port type to PORT_OTHER
> v5: null diff1.port because we set cmd->port now and ethtool returns it in
> the set request, retested all cases
> 

Hmm, nulling the advertising and ->port completely ignores them, i.e. won't produce
an error if the user actually specified a different value for either of them.
We can check if the ->port matches what we returned, but there's no fix for
advertising. I'm leaving both ignored for now, please let me know if you'd
prefer otherwise.

Thanks,
 Nik
