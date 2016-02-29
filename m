From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 28/32] Documentation: DSA: Describe how probe of
 DSA and switches work.
Date: Mon, 29 Feb 2016 14:42:40 +0300
Message-ID: <56D42EB0.3080304@cogentembedded.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-29-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35752 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcB2Lmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 06:42:43 -0500
Received: by mail-lf0-f47.google.com with SMTP id j186so15008409lfg.2
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 03:42:42 -0800 (PST)
In-Reply-To: <1456677700-23027-29-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/28/2016 7:41 PM, Andrew Lunn wrote:

> With the introduction of switches as linux devices and the use of the
> component framework, probing has become more complex. Add some
> documentation.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>   Documentation/networking/dsa/dsa.txt | 48 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 48 insertions(+)
>
> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
> index aa9c1f9313cd..376afa135a81 100644
> --- a/Documentation/networking/dsa/dsa.txt
> +++ b/Documentation/networking/dsa/dsa.txt
> @@ -398,6 +398,54 @@ Switch configuration
>     on the management interface and "hardcode"/"force" this MAC address for the
>     CPU/management interface as an optimization
>
> +Call flow
> +---------
> +
> +With the ability for switch devices to be true linux devices, the call

    Linux.

> +flow is somewhat complex. The component framework is used to link the
> +dsa framework as the master, with switch devices, as slaves.

    Commas not needed before "as".

> +
> +A switch device should add itself as a component in its probe
> +function.
> +
> +The DSA framework can either be configured using a platform_data
> +structure or from the device tree. If device tree is being used, the
> +dsa framework probe function will allocate a platform_data structure,
> +and populate it using the device tree, via the dsa_of_probe()
> +function.  Within the DSA device tree, switch devices are represented
> +by a phandle to the switch device. These phandles are saved into the
> +platform data so that when switch slaves register themselves, they can
> +be correctly positioned in the DSA cluster.
> +
> +The DSA probe function then creates a dsa_switch_tree structure which
> +is the overarching structure representing a switch cluster. The probe
> +function then looks in the platform data for the phandles to slave

    Platform data and phandles?

> +devices, and adds a component match based on the phandle. The
> +component master is then created. This causes the component framework
> +to link slaves to the master.
> +
> +If all the slave switch can be found, the masters bind function is

    Switches? Master's?

> +called, dsa_bind(). This in tern causes the switch slaves bind

    In term?

> +function to be called.
> +
> +The switches bind function allocated memory for its own private use,

    Switch's?

> +and for a dsa_switch structure, which represents one switch in a DSA
> +cluster. The switch then registers with the DSA framework using
> +dsa_switch_register().
> +
> +dsa_switch_register() looks in the platform data and finds the
> +position within the cluster for the switch which is registering. The
> +switches dsa_switch structure is then attached to the dsa_switch_tree

    Switch's?

> +structure in the correct place.
[...]

MBR, Sergei
