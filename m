From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: io_error_detected callback should return
 PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Mon, 01 Jun 2009 18:26:51 -0700 (PDT)
Message-ID: <20090601.182651.227000394.davem@davemloft.net>
References: <4A2050B8.7050302@us.ibm.com>
	<9929d2390906011643q3967535cue22345e6a40a4b14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mmlnx@us.ibm.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754708AbZFBB0v convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2009 21:26:51 -0400
In-Reply-To: <9929d2390906011643q3967535cue22345e6a40a4b14@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 1 Jun 2009 16:43:39 -0700

> On Fri, May 29, 2009 at 2:16 PM, Mike Mason <mmlnx@us.ibm.com> wrote:
>> PCI drivers that implement the io_error_detected callback
>> should return PCI_ERS_RESULT_DISCONNECT if the state
>> passed in is pci_channel_io_perm_failure. =A0This state is not check=
ed in many
>> of the network drivers.
>>
>> This patch fixes the omission in the e1000e driver.
>>
>> Signed-off-by: Mike Mason <mmlnx@us.ibm.com>
>> --- a/drivers/net/e1000e/netdev.c =A0 =A0 =A0 2009-05-23 14:47:00.00=
0000000 -0700
>> +++ b/drivers/net/e1000e/netdev.c =A0 =A0 =A0 2009-05-29 13:43:24.00=
0000000 -0700
>> @@ -4616,6 +4616,9 @@ static pci_ers_result_t e1000_io_error_d
>>
>> =A0 =A0 =A0 =A0netif_device_detach(netdev);
>>
>> + =A0 =A0 =A0 if (state =3D=3D pci_channel_io_perm_failure)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PCI_ERS_RESULT_DISCONNECT;
>> +
>> =A0 =A0 =A0 =A0if (netif_running(netdev))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000e_down(adapter);
>> =A0 =A0 =A0 =A0pci_disable_device(pdev);
>>
>> --
>=20
> Looks good.
>=20
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Jeff, can you simply queue this up into the next batch of Intel
driver bits you send to me?

Thanks!
