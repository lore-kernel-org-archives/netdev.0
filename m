From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix error handling if slave is busy (v2)
Date: Tue, 03 Jan 2012 12:49:35 -0500 (EST)
Message-ID: <20120103.124935.657537317702636488.davem@davemloft.net>
References: <4EFF3419.4050504@gmail.com>
	<20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>
	<4EFFA44E.10507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab2ACRtn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:49:43 -0500
In-Reply-To: <4EFFA44E.10507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Sun, 01 Jan 2012 01:09:50 +0100

> Le 01/01/2012 00:26, Stephen Hemminger a =E9crit :
>> If slave device already has a receive handler registered, then the
>> error unwind of bonding device enslave function is broken.
>>
>> The following will leave a pointer to freed memory in the slave
>> device list, causing a later kernel panic.
>> # modprobe dummy
>> # ip li add dummy0-1 link dummy0 type macvlan
>> # modprobe bonding
>> # echo +dummy0>/sys/class/net/bond0/bonding/slaves
>>
>> The fix is to detach the slave (which removes it from the list)
>> in the unwind path.
>>
>> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>=20
> Thanks Stephen.
>=20
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied, thanks.
