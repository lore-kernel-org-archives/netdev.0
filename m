From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Wed, 3 Feb 2016 16:39:47 +0000
Message-ID: <BN1PR0301MB07709B6ACC8E6C969CB5B857CAD00@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
 <87si1ax7t9.fsf@vitty.brq.redhat.com>
 <BN1PR0301MB0770CFE76823654E90579D0CCAD00@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <87d1sdye0x.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87d1sdye0x.fsf@vitty.brq.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Wednesday, February 3, 2016 11:06 AM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan
> <kys@microsoft.com>; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> driverdev-devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
> RNDIS_STATUS_NETWORK_CHANGE
> 
> Haiyang Zhang <haiyangz@microsoft.com> writes:
> 
> >> -----Original Message-----
> >> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> >> Sent: Wednesday, February 3, 2016 8:06 AM
> >> To: Haiyang Zhang <haiyangz@microsoft.com>
> >> Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan
> >> <kys@microsoft.com>; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> >> driverdev-devel@linuxdriverproject.org
> >> Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
> >> RNDIS_STATUS_NETWORK_CHANGE
> >>
> >> Haiyang Zhang <haiyangz@microsoft.com> writes:
> >>
> >> > We simulates a link down period for
> RNDIS_STATUS_NETWORK_CHANGE
> >> message to
> >> > trigger DHCP renew. User daemons may need multiple seconds to
> trigger
> >> the
> >> > link down event. (e.g. ifplugd: 5sec, network-manager: 4sec.) So update
> >> > this link down period to 10 sec to properly trigger DHCP renew.
> >> >
> >>
> >> I probably don't follow: why do we need sucha a delay? If (with real
> >> hardware) you plug network cable out and in one second you plug it in
> >> you'll get DHCP renewed, right?
> >>
> >> When I introduced RNDIS_STATUS_NETWORK_CHANGE handling by
> >> emulating a
> >> pair of up/down events I put 2 second delay to make link_watch happy
> (as
> >> we only handle 1 event per second there) but 10 seconds sounds to much
> >> to me.
> >
> > In the test on Hyper-V, our software on host side  wants to trigger DHCP
> > renew by sending only a RNDIS_STATUS_NETWORK_CHANGE message to
> > a guest without physically unplug the cable. But, this message didn't trigger
> > DHCP renew within 2 seconds. The VM is Centos 7.1 using
> Networkmanager,
> > which needs 4 seconds after link down to renew IP. Some daemon, like
> > ifplugd, needs 5 sec to renew. That's why we increase the simulated link
> > down time for RNDIS_STATUS_NETWORK_CHANGE message.
> 
> Yes, I understand the motivation but sorry if I was unclear with my
> question. I meant to say that with physical network adapters it's
> possible to trigger same two events by plugging your cable out and then
> plugging it back in and it is certailnly doable in less than 10
> seconds. NetworkManager or whoever is supposed to handle these events
> and we don't really care how fast -- I think that 4 or 5 seconds
> mentioned above is just an observation.

(forgot mailing lists in my last reply.... re-sending...)

Our test failed (i.e. not triggering DHCP renew) with existing 2sec delay. According 
to the ifplugd man page, it ignores link down time <5sec:
  http://linux.die.net/man/8/ifplugd
    -d | --delay-down= SECS Specify delay for deconfiguring interface (default: 5)

Networkmanager also has a waiting period (4sec).

Thanks,
- Haiyang
