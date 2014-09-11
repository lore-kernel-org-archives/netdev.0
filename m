From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/7] bonding: get rid of curr_slave_lock
Date: Thu, 11 Sep 2014 14:40:26 +0200
Message-ID: <5411983A.5010306@redhat.com>
References: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbaIKMke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 08:40:34 -0400
In-Reply-To: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/14 13:38, Nikolay Aleksandrov wrote:
> Hi all,
> This is the second patch-set dealing with bond locking and the purpose here
> is to convert curr_slave_lock into a spinlock called "mode_lock" which can
> be used in the various modes for their specific needs. The first three
> patches cleanup the use of curr_slave_lock and prepare it for the
> conversion which is done in patch 4 and then the modes that were using
> their own locks are converted to use the new "mode_lock" giving us the
> opportunity to remove their locks.
> This patch-set has been tested in each mode by running enslave/release of
> slaves in parallel with traffic transmission and miimon=1 i.e. running
> all the time. In fact this lead to the discovery of a subtle bug related to
> RCU which will be fixed in -net.
> Also did an allmodconfig test just in case :-)
>
> Best regards,
>   Nikolay Aleksandrov
>
>
> Nikolay Aleksandrov (7):
>    bonding: 3ad: clean up curr_slave_lock usage
>    bonding: alb: remove curr_slave_lock
>    bonding: clean curr_slave_lock use
>    bonding: convert curr_slave_lock to a spinlock and rename it
>    bonding: alb: convert to bond->mode_lock
>    bonding: 3ad: convert to bond->mode_lock
>    bonding: adjust locking comments
>
>   drivers/net/bonding/bond_3ad.c     |  76 ++++++------------
>   drivers/net/bonding/bond_3ad.h     |   1 -
>   drivers/net/bonding/bond_alb.c     | 159 +++++++++----------------------------
>   drivers/net/bonding/bond_alb.h     |   2 -
>   drivers/net/bonding/bond_debugfs.c |   4 +-
>   drivers/net/bonding/bond_main.c    |  89 ++++-----------------
>   drivers/net/bonding/bond_options.c |  10 +--
>   drivers/net/bonding/bonding.h      |  16 ++--
>   8 files changed, 89 insertions(+), 268 deletions(-)
>
Self-NAK, I've missed one obvious spot in the 3ad state machine handler that 
also uses lag_ports instead of the slave list and needs to be fixed.

Anyhow, I'll wait until tonight before submitting v2 with the fix to see if 
there're any other comments.
