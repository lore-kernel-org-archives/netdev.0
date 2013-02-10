From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [net-next (TAKE 2) 3/4] firewire net, ipv4 arp: Extend hardware
 address and remove driver-level packet inspection.
Date: Mon, 11 Feb 2013 01:32:48 +0900
Message-ID: <5117CBB0.3030000@linux-ipv6.org>
References: <51176223.8090305@linux-ipv6.org> <20130210151056.3e6e9f53@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37059 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754516Ab3BJQct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 11:32:49 -0500
In-Reply-To: <20130210151056.3e6e9f53@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B402=E6=9C=8810=E6=97=A5 23:10), Stefan Richter wrote:
> On Feb 10 YOSHIFUJI Hideaki wrote:
>> @@ -1140,18 +1051,6 @@ static int fwnet_broadcast_start(struct fwnet=
_device *dev)
>>  	unsigned long offset;
>>  	unsigned u;
>> =20
>> -	if (dev->local_fifo =3D=3D FWNET_NO_FIFO_ADDR) {
>> -		dev->handler.length =3D 4096;
>> -		dev->handler.address_callback =3D fwnet_receive_packet;
>> -		dev->handler.callback_data =3D dev;
>> -
>> -		retval =3D fw_core_add_address_handler(&dev->handler,
>> -					&fw_high_memory_region);
>> -		if (retval < 0)
>> -			goto failed_initial;
>> -
>> -		dev->local_fifo =3D dev->handler.offset;
>> -	}
>> =20
>>  	max_receive =3D 1U << (dev->card->max_receive + 1);
>>  	num_packets =3D (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
>> @@ -1234,8 +1133,6 @@ static int fwnet_broadcast_start(struct fwnet_=
device *dev)
>>  	dev->broadcast_rcv_context =3D NULL;
>>   failed_context_create:
>>  	fw_core_remove_address_handler(&dev->handler);
>> - failed_initial:
>> -	dev->local_fifo =3D FWNET_NO_FIFO_ADDR;
>> =20
>>  	return retval;
>>  }
>=20
> [...]
>=20
>> @@ -1546,12 +1421,21 @@ static int fwnet_probe(struct device *_dev)
>>  	dev->broadcast_rcv_context =3D NULL;
>>  	dev->broadcast_xmt_max_payload =3D 0;
>>  	dev->broadcast_xmt_datagramlabel =3D 0;
>> -	dev->local_fifo =3D FWNET_NO_FIFO_ADDR;
>>  	dev->queued_datagrams =3D 0;
>>  	INIT_LIST_HEAD(&dev->peer_list);
>>  	dev->card =3D card;
>>  	dev->netdev =3D net;
>> =20
>> +	dev->handler.length =3D 4096;
>> +	dev->handler.address_callback =3D fwnet_receive_packet;
>> +	dev->handler.callback_data =3D dev;
>> +
>> +	ret =3D fw_core_add_address_handler(&dev->handler, &fw_high_memory=
_region);
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	dev->local_fifo =3D dev->handler.offset;
>> +
>>  	/*
>>  	 * Use the RFC 2734 default 1500 octets or the maximum payload
>>  	 * as initial MTU
>=20
> If at all possible, please put changes of this kind into a separate
> patch.
>=20
> I get a distinct feeling that the error handling paths in
> fwnet_broadcast_start() and in fwnet_probe() respectively became bugg=
y now.
> This would be easier to verify if shifting this code was done in a se=
parate
> change.

Will do.

--yoshfuji
