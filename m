From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/2] bonding: add sysfs /slave dir for bond
 slave devices.
Date: Thu, 16 Jan 2014 19:40:30 +0100
Message-ID: <20140116184030.GA24396@redhat.com>
References: <20140116055434.32220.89883.stgit@monster-03.cumulusnetworks.com>
 <20140116153142.GD1896@redhat.com>
 <B1B4CB0E-6A3C-4023-9911-D57B5F58D691@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbaAPSn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 13:43:29 -0500
Content-Disposition: inline
In-Reply-To: <B1B4CB0E-6A3C-4023-9911-D57B5F58D691@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 10:04:31AM -0800, Scott Feldman wrote:
>
>On Jan 16, 2014, at 7:31 AM, Veaceslav Falico <vfalico@redhat.com> wro=
te:
>
>> On Wed, Jan 15, 2014 at 09:54:34PM -0800, Scott Feldman wrote:
>>> Add sub-directory under /sys/class/net/<interface>/slave with
>>> read-only attributes for slave.  Directory only appears when
>>> <interface> is a slave.
>
>>> +static ssize_t state_show(struct slave *slave, char *buf)
>>> +{
>>> +	switch (bond_slave_state(slave)) {
>>> +	case BOND_STATE_ACTIVE:
>>> +		return sprintf(buf, "active\n");
>>> +	case BOND_STATE_BACKUP:
>>> +		return sprintf(buf, "backup\n");
>>> +	default:
>>> +		return sprintf(buf, "UNKONWN\n");
>>> +	}
>>> +}
>>> +static SLAVE_ATTR_RO(state);
>>
>> Am I missing something or does it really completely lacks any lockin=
g?
>>
>> What prevents the slave to be freed in between?
>
>Correct me if I=E2=80=99m wrong, but I think the equivalent question i=
s: is there a race between sysfs_remove_file() and another CPU open on =
that file trying to read/write the file?  I believe the answer is no, b=
ut I=E2=80=99ll defer to the experts.
>
>The file removal call path is:
>
>=09
>	bond_release (ndo_del_slave)
>		__bond_release_one
>			bond_sysfs_slave_del
>				sysfs_remove_file
>			<...continue freeing slave...>
>
>So slave is freed after sysfs_remove_file.  I would expect I/O on sysf=
s file to fail during sysfs_remove_file.
>
>Does this sound OK?  Am I missing anything else?

Yeah, totally, and as they're read-only there's no locking needed indee=
d.

>
>-scott
>	=09
