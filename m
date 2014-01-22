From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] net: Correctly sync addresses from multiple sources to
 single device
Date: Wed, 22 Jan 2014 10:30:45 -0500
Message-ID: <52DFE425.2090404@redhat.com>
References: <1389988332-22472-1-git-send-email-vyasevic@redhat.com> <20140121.145355.1406240839568386348.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andrey.dmitrov@oktetlabs.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34246 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550AbaAVPay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 10:30:54 -0500
In-Reply-To: <20140121.145355.1406240839568386348.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2014 05:53 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Fri, 17 Jan 2014 14:52:12 -0500
>=20
>> When we have multiple devices attempting to sync the same address
>> to a single destination, each device should be permitted to sync
>> it once.  To accomplish this, pass the sync count of the source
>> address to __hw_addr_add_ex().  'sync_cnt' tracks how many time
>> a given address has been successfully synced.  If the address
>> is found in the destination list, but the 'sync_cnt' of the source
>> is 0, then this address has not been synced from this interface
>> and we need to allow the sync operation to succeed thus incrementing
>> reference counts.
>>
>> Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
>> CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>=20
> I applied this to net-next since 3.13 just got released, and it doesn=
't
> compile.
>=20
> net/core/dev_addr_lists.c: In function =A1__hw_addr_sync_one=A2:
> net/core/dev_addr_lists.c:144:26: error: =A1struct netdev_hw_addr=A2 =
has no member named =A1sync_count=A2
>=20

That does it...  Time to add a hook to format_patch to check for dirty
index.

-vlad
