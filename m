From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 2/3] net: dsa: mv88e6xxx: add support for VTU operations
Date: Fri, 29 May 2015 15:38:07 -0700
Message-ID: <5568EA4F.2040705@roeck-us.net>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1432849035-8499-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:36450 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbbE2WiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 18:38:11 -0400
In-Reply-To: <1432849035-8499-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

On 05/28/2015 02:37 PM, Vivien Didelot wrote:
> This commit implements the port_vlan_add, port_vlan_kill, and
> port_bridge_setlink dsa_switch_driver functions to access the VTU, and
> thus add support for adding, removing VLANs, and joining ports to them.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Pretty much similar to what I have, except for the stu part
which I have completely missing, and I use the default port FIDs.

I wonder if we can really use 'fid = DSA_MAX_PORTS + vid'.
Problem I see is that there may be multiple bridge groups on a switch,
and some ports may not be part of a bridge group. If the same fid is used
for the same vid on multiple ports which belong to different bridge groups,
don't we get into trouble with the address database ?

My assumption was that we have to use a separate fid for each vid per
bridge group (or port if the port is not in a bridge group) if 802.1s
is used, and that we should be able to use the port fid otherwise.
Is that wrong ?

When reporting addresses, how do we associate fdb entries to a vid ?
Or, in other words, how do we handle the fdb entries associated
with a fid in __mv88e6xxx_port_getnext ?

Thanks,
Guenter
