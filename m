From: Jamie Lentin <jm@lentin.co.uk>
Subject: Re: [PATCH 0/4] Fix MV88E6131 tagging
Date: Mon, 22 Aug 2016 15:36:29 +0100 (BST)
Message-ID: <alpine.DEB.2.11.1608221529480.19980@marmot.wormnet.eu>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from marmot.wormnet.eu ([188.246.204.87]:52882 "EHLO
        marmot.wormnet.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755117AbcHVPDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 11:03:03 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016, Andrew Lunn wrote:

> Marvell has two different tagging protocols for frames passed to a
> swicth. There is the older DSA and the newer EDSA. Somewhere along the
> way, we broke support for switches which only support DSA, by trying
> to configure them to use EDSA. These patches add back support for
> switches which only support DSA, by allowing the drivers to
> dynamically indicate the tagging protocol they support to the DSA
> core. This needs to be dynamic since the mv88e6xxx has to support two
> protocols.
>
> Thanks go to Jamie Lentin for reporting the problem, helping debug it,
> providing some of the fix, and testing.

Entire series tested on a Netgear WNR854T With a mv88e6131 switch chip.

Tested-By: Jamie Lentin <jm@lentin.co.uk>

> Andrew Lunn (3):
>  net: dsa: Allow the DSA driver to indicate the tag protocol
>  net: dsa: mv88e6xxx: Fix support for DSA tagging for older switches.
>  dsa: mv88e6xxx: Delete ppu timer when removing module
>
> Jamie Lentin (1):
>  net: mv88e6xxx: Enable PORT_CONTROL_FORWARD_UNKNOWN for DSA-tagged CPU
>    ports
>
> drivers/net/dsa/b53/b53_common.c      |  7 +++-
> drivers/net/dsa/bcm_sf2.c             |  7 +++-
> drivers/net/dsa/mv88e6060.c           |  7 +++-
> drivers/net/dsa/mv88e6xxx/Kconfig     |  1 +
> drivers/net/dsa/mv88e6xxx/chip.c      | 61 +++++++++++++++++++++--------------
> drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 16 +++++++--
> include/net/dsa.h                     |  5 +--
> net/dsa/dsa.c                         |  5 ++-
> net/dsa/dsa2.c                        |  4 ++-
> 9 files changed, 78 insertions(+), 35 deletions(-)
>
>

-- 
Jamie Lentin
