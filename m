From: lpechacek@suse.cz
Subject: Re: [PATCH] bonding: Fix sysfs attribute handling
Date: Sun, 23 Mar 2008 21:05:05 +0100 (CET)
Message-ID: <27198.10.20.10.50.1206302705.squirrel@webmail.suse.cz>
References: <200803211452.55982.lpechacek@suse.cz>
    <20080322172704.49fa557b.akpm@linux-foundation.org>
    <18749.1206234754@death>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Libor Pechacek" <lpechacek@suse.cz>,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable@kernel.org
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37415 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755982AbYCWUFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:05:12 -0400
In-Reply-To: <18749.1206234754@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>>On Fri, 21 Mar 2008 14:52:55 +0100 Libor Pechacek <lpechacek@suse.cz>
>> wrote:
>>
>>> bonding: Fix sysfs attribute handling
>>>
>>> For bonding interfaces any attempt to read the sysfs directory contents
>>> after
>>> module removal results in an oops.  The fix is to release sysfs
>>> attributes
>>> for the interfaces upon module unload.
>>>
>>> Signed-off-by: Libor Pechacek <lpechacek@suse.cz>
>>> --
>>>  drivers/net/bonding/bond_main.c |    3 +--
>>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c
>>> b/drivers/net/bonding/bond_main.c
>>> index 0942d82..33767d4 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -4528,8 +4528,7 @@ static void bond_free_all(void)
>>>  		netif_tx_unlock_bh(bond_dev);
>>>  		/* Release the bonded slaves */
>>>  		bond_release_all(bond_dev);
>>> -		bond_deinit(bond_dev);
>>> -		unregister_netdevice(bond_dev);
>>> +		bond_destroy(bond);
>>>  	}
>>
>>Is this also needed in 2.6.24.x?
>
> 	Yes (I haven't tested it personally, but the affected code is
> the same).  I was going to forward this to stable when it was accepted
> upstream.  The oops is fairly straightforward to create:
>
> # modprobe bonding
> # cd /sys/class/net/bond0/bonding
> # rmmod bonding
> # ls

Yes, exactly.

I tested the patch with the latest Linus' tree (GIT commit
49a5ba46c5d1e34bcb07634157b29d7414ce13bd), but I first found the bug in
2.6.16.

Libor

