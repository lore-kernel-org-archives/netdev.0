From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next 2/2] bonding: Implement port churn-machine (AD standard
 43.4.17).
Date: Tue, 24 Feb 2015 18:39:28 +0100
Message-ID: <54ECB750.3050108@redhat.com>
References: <1424742611-6698-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739AbbBXRjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 12:39:45 -0500
In-Reply-To: <1424742611-6698-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 02:50 AM, Mahesh Bandewar wrote:
> The Churn Detection machines detect the situation where a port is operable,
> but the Actor and Partner have not attached the link to an Aggregator and
> brought the link into operation within a bound time period. Under normal
> operation of the LACP, agreement between Actor and Partner should be reached
> very rapidly. Continued failure to reach agreement can be symptomatic of
> device failure.
> 
> Actor-churn-detection state-machine
> ===================================
> 
> BEGIN=True + PortEnable=False
>            |
>            v
>  +------------------------+   ActorPort.Sync=True  +------------------+
>  |   ACTOR_CHURN_MONITOR  | ---------------------> |  NO_ACTOR_CHURN  |
>  |========================|                        |==================|
>  |    ActorChurn=False    |  ActorPort.Sync=False  | ActorChurn=False |
>  | ActorChurn.Timer=Start | <--------------------- |                  |
>  +------------------------+                        +------------------+
>            |                                                ^
>            |                                                |
>   ActorChurn.Timer=Expired                                  |
>            |                                       ActorPort.Sync=True
>            |                                                |
>            |                +-----------------+             |
>            |                |   ACTOR_CHURN   |             |
>            |                |=================|             |
>            +--------------> | ActorChurn=True | ------------+
>                             |                 |
>                             +-----------------+
> 
> Similar for the Partner-churn-detection.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_3ad.c    | 57 +++++++++++++++++++++++++++++++++++++--
>  drivers/net/bonding/bond_procfs.c | 43 +++++++++++++++++++++++++----
>  include/net/bond_3ad.h            | 29 ++++++++++++++++++++
>  3 files changed, 122 insertions(+), 7 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
