From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: a question on net_device struct
Date: Tue, 11 Aug 2009 09:12:13 -0700
Message-ID: <20090811091213.0f9068c3@nehalam>
References: <2014bcab0908110757q5b255dcdm497414d04810c281@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?7ZmN7Iug?= shin hong <hongshin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46951 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbZHKQMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 12:12:19 -0400
In-Reply-To: <2014bcab0908110757q5b255dcdm497414d04810c281@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2009 23:57:31 +0900
=ED=99=8D=EC=8B=A0 shin hong <hongshin@gmail.com> wrote:

> Hi. I have a question while I read the codes in net/core of Linux 2.6=
=2E30.4.
>=20
> 'net_device' struct defined in include/linux/netdevice.h has a field
> 'operstate'.
> Is a 'operstate' field is protected by 'dev_base_lock'?
>=20
> At set_operstate() in net/core/rtnetlink.c, it seems that dev->operst=
ate
> is protected by write_lock_bh(&dev_base_lock).
> But, in other codes, the read operations to dev->operstate are not
> consistently protected by read_lock_bh(&dev_base_lock).
>=20

Should be protected by RTNL mutex being held (see rtnl_lock() ).
The dev_base_lock is intended for the list of devices. Operations
that add and delete devices end up holding both.
