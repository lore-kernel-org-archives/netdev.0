From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net 3/3] Documentation: networking: dsa: Describe port_vlan_filtering
Date: Tue, 24 May 2016 10:32:33 -0400
Message-ID: <871t4rsf0e.fsf@ketchup.mtl.sfl>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com> <1464064337-8743-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50414 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbcEXOch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 10:32:37 -0400
In-Reply-To: <1464064337-8743-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Described what the port_vlan_filtering function is supposed to
> accomplish.
>
> Fixes: fb2dabad69f0 ("net: dsa: support VLAN filtering switchdev attr")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  Documentation/networking/dsa/dsa.txt | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
> index 411b57fd73aa..a42fd2ec32a5 100644
> --- a/Documentation/networking/dsa/dsa.txt
> +++ b/Documentation/networking/dsa/dsa.txt
> @@ -535,6 +535,12 @@ Bridge layer
>  Bridge VLAN filtering
>  ---------------------
>  
> +- port_vlan_filtering: bridge layer function invoked when the bridge gets
> +  configured for turning on or off VLAN filtering. If nothing specific needs to
> +  be done at the hardware level, 0 must be returned. When VLAN filtering is
> +  turned on, the hardware must be programmed with rejecting non-802.1Q frames,
> +  when turned off the switch must accept any 802.1Q frames.

Note that port_vlan_filtering is optional so a driver don't need to
implement it if nothing specific needs to be done at the hardware level.

Also I'd think that with VLAN filtering on, the hardware must not reject
untagged frames, only 802.1Q frames which don't respect the programmed
VLAN rules.

Thanks,

        Vivien
