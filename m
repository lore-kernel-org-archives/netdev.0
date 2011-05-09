From: Jesse Gross <jesse@nicira.com>
Subject: Re: Scalability of interface creation and deletion
Date: Mon, 9 May 2011 10:30:08 -0700
Message-ID: <BANLkTi=BdTaudvQJ=CVkNX1MNmH81ZFk6A@mail.gmail.com>
References: <1304793749.3207.26.camel@edumazet-laptop> <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local> <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com> <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com> <C449131127D58077CB25C9D8@Ximines.local>
 <20110508144749.GR2641@linux.vnet.ibm.com> <AB9DE9E04289CF29CA79CC67@Ximines.local>
 <20110508154854.GT2641@linux.vnet.ibm.com> <1304888447.3207.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: paulmck@linux.vnet.ibm.com, Alex Bligh <alex@alex.org.uk>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:33978 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab1EIRa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 13:30:29 -0400
Received: by qyg14 with SMTP id 14so4144285qyg.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 10:30:29 -0700 (PDT)
In-Reply-To: <1304888447.3207.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2011 at 2:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> For example, in the VLAN dismantle phase (ip link del eth0.103)
> we have 3 calls to synchronize_rcu() and one call to rcu_barrier()
>
> [ the 'extra' synchronize_rcu() call comes from unregister_vlan_dev() ]
>
> Maybe with new VLAN model, we could now remove this synchronize_net()
> call from vlan code. Jesse what do you think ?
> Once vlan_group_set_device(grp, vlan_id, NULL) had been called, why
> should we respect one rcu grace period at all, given dev is queued to
> unregister_netdevice_queue() [ which has its own couples of
> synchronize_net() / rcu_barrier() ]

Yes, I agree that the extra call to synchronize_net() provides no
value, though I think that's actually been true for a while.
