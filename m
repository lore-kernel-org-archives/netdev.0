From: Laurent Chavey <chavey@google.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
	cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 10:49:17 -0800
Message-ID: <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
	<20091217074930.GA6779@ff.dom.local> <20091217133644.GD8654@ff.dom.local>
	<1261060259.10356.112.camel@johannes.local> <11218.1261066373@death.nxdomain.ibm.com>
	<20091217184017.GA2578@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:50908 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936596AbZLQStk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 13:49:40 -0500
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id nBHIncIU011101
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 10:49:39 -0800
Received: from pxi40 (pxi40.prod.google.com [10.243.27.40])
	by kpbe16.cbf.corp.google.com with ESMTP id nBHIn8SK029803
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 10:49:37 -0800
Received: by pxi40 with SMTP id 40so1703324pxi.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 10:49:37 -0800 (PST)
In-Reply-To: <20091217184017.GA2578@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

one instance that could be a problem

__exit bonding_exit(void)
    bond_free_all()
      	bond_work_cancel_all(bond);
        unregister_netdevice(bond_dev)

could the above result in an invalid pointer when trying
to use bond-> in one of the timer CB ?


On Thu, Dec 17, 2009 at 10:40 AM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> On Thu, Dec 17, 2009 at 08:12:53AM -0800, Jay Vosburgh wrote:
>> =A0 =A0 =A0 There's already logic in the monitors (bond_mii_monitor,=
 et al)
>> to check a sentinel (kill_timers) and do nothing (not acquire rtnl) =
and
>> return.
>
> Btw, this check should be repeated if bond->lock is given back and
> re-acquired. I can't see these kill_timers used in bond_sysfs.c thoug=
h.
>
>> =A0 =A0 =A0 What exactly is the nature of the race that doing cancel=
=2E.sync
>> is fixing? =A0The bond_close function sets kill_timers prior to call=
ing
>> the cancel functions, so the monitor function might run once, but it
>> should do nothing.
>
> I guess there is a problem with destructions, but I hope Mikhail will
> give more details.
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
