From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next 0/5] bonding: winter cleanup
Date: Wed, 08 Mar 2017 15:24:06 -0800
Message-ID: <17528.1489015446@famine>
References: <20170308185545.22864-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52962 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdCIACX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 19:02:23 -0500
In-reply-to: <20170308185545.22864-1-mahesh@bandewar.net>
Content-ID: <17527.1489015446.1@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <mahesh@bandewar.net> wrote:

>From: Mahesh Bandewar <maheshb@google.com>
>
>Few cleanup patches that I have accumulated over some time now.
>
>(a) First two patches are basically to move the work-queue initialization
>    from every ndo_open / bond_open operation to once at the beginning while
>    port creation. Work-queue initialization is an unnecessary operation
>    for every 'ifup' operation. However we have some mode-specific work-queues
>    and mode can change anytime after port creation. So the second patch is
>    to ensure the correct work-handler is called based on the mode.
>
>(b) Third patch is simple and straightforward that removes hard-coded value
>    that was added into the initial commit and replaces it with the default
>    value configured.
>
>(c) The final patch in the series removes the unimplemented "port-moved" state
>    from the LACP state machine. This state is defined but never set so
>    removing from the state machine logic makes code little cleaner.
>
>(d) Reduce scope of some global variables to local.

	For all patches in the series:

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

>Note: None of these patches are making any functional changes.
>
>Mahesh Bandewar (5):
>  bonding: restructure arp-monitor
>  bonding: initialize work-queues during creation of bond
>  bonding: remove hardcoded value
>  bonding: remove "port-moved" state that was never implemented
>  bonding: reduce scope of some global variables
>
> drivers/net/bonding/bond_3ad.c  | 11 +++------
> drivers/net/bonding/bond_main.c | 53 ++++++++++++++++++++++++++---------------
> 2 files changed, 37 insertions(+), 27 deletions(-)
>
>-- 
>2.12.0.246.ga2ecc84866-goog

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
