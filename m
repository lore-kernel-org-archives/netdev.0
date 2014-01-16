From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] bonding: add sysfs /slave dir for bond slave devices.
Date: Thu, 16 Jan 2014 11:00:25 -0800
Message-ID: <CF899207-69CB-4D44-B820-8C2422315CD1@cumulusnetworks.com>
References: <20140116055434.32220.89883.stgit@monster-03.cumulusnetworks.com> <20140116184441.GB24396@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48096 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAPTB0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:01:26 -0500
In-Reply-To: <20140116184441.GB24396@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 16, 2014, at 10:44 AM, Veaceslav Falico <vfalico@redhat.com> wro=
te:

> On Wed, Jan 15, 2014 at 09:54:34PM -0800, Scott Feldman wrote:
> ...snip...
>> +	res =3D bond_sysfs_slave_add(new_slave);
>> +	if (res) {
>> +		pr_debug("Error %d calling bond_sysfs_slave_add\n", res);
>> +		goto err_upper_unlink;
>> +	}
>> +
>> 	bond->slave_cnt++;
>> 	bond_compute_features(bond);
>> 	bond_set_carrier(bond);
>> @@ -1595,6 +1617,9 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>> 	return 0;
>>=20
>> /* Undo stages on error */
>> +err_upper_unlink:
>> +	bond_upper_dev_unlink(bond_dev, slave_dev);
>> +
>> err_unregister:
>> 	netdev_rx_handler_unregister(slave_dev);
>>=20
>=20
> In case bond_sysfs_slave_add() creates the kobject, but fails to crea=
te the
> attributes, we'll end up with a mem leak, as we don't do kobject_put(=
) on
> it.

I=92ll fix this and the other one Ding found and send v2.  Thanks for r=
eviewing!

-scott