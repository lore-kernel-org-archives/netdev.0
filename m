From: Jeff Garzik <jeff@garzik.org>
Subject: Re: possible bug in net/tc35815.c in linux-2.6.19
Date: Sat, 24 Feb 2007 17:04:01 -0500
Message-ID: <45E0B651.2050601@garzik.org>
References: <45DFEC09.3020801@cs.stanford.edu> <45E031A3.806@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Philip Guo <pg@cs.stanford.edu>, ahennessy@mvista.com,
	netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57440 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932609AbXBXWEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Feb 2007 17:04:09 -0500
In-Reply-To: <45E031A3.806@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski wrote:
> Hi Philip,
>=20
> Philip Guo napisa=C5=82(a):
>> Hi,
>>
>> I am a graduate student working on finding bugs in Linux drivers usi=
ng
>> an automated research tool.  I think I've found a possible bug in
>> net/tc35815.c, and I'd appreciate it if you could confirm/disconfirm=
 it.
>>
>> Thanks,
>> Philip
>>
>> ---
>> net/tc35815.c
>>
>> tc35815_driver is never unregistered in tc35815_cleanup_module()
>>
>> static int __init tc35815_init_module(void)
>> {
>>     return pci_register_driver(&tc35815_driver);
>> }
>>
>> static void __exit tc35815_cleanup_module(void)
>> {
>>     struct net_device *next_dev;
>>
>>     while (root_tc35815_dev) {
>>         struct net_device *dev =3D root_tc35815_dev;
>>         next_dev =3D ((struct tc35815_local *)dev->priv)->next_modul=
e;
>>         iounmap((void *)(dev->base_addr));
>>         unregister_netdev(dev);
>>         free_netdev(dev);
>>         root_tc35815_dev =3D next_dev;
>>     }
>> }
>>
>>
>=20
> I think that you are right, but I don't know this code.
>=20
> Jeff, what do you think about this?
>=20
> Regards,
> Michal

I created my own patch for this (and one other bug), and checked it in.

Really, though, someone in MIPS-land should give this driver some lovin=
g=20
care.  It is filled with bugs and 2.4-era anachronisms.

	Jeff



