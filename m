From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Wed, 12 Dec 2012 20:06:13 +0100
Message-ID: <20121212190613.GE3060@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
 <20121212081500.24085752@nehalam.linuxnetplumber.net>
 <20121212170520.GA3060@minipsycho.orion>
 <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
 <20121212181017.GB3060@minipsycho.orion>
 <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
 <20121212182556.GC3060@minipsycho.orion>
 <20121212103632.2020efce@nehalam.linuxnetplumber.net>
 <20121212184925.GD3060@minipsycho.orion>
 <20121212105448.490aca5c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:65452 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149Ab2LLTGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 14:06:25 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so359237eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 11:06:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121212105448.490aca5c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 12, 2012 at 07:54:48PM CET, shemminger@vyatta.com wrote:
>On Wed, 12 Dec 2012 19:49:26 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Wed, Dec 12, 2012 at 07:36:32PM CET, shemminger@vyatta.com wrote:
>> >On Wed, 12 Dec 2012 19:25:56 +0100
>> >Jiri Pirko <jiri@resnulli.us> wrote:
>> >
>> >> Wed, Dec 12, 2012 at 07:12:08PM CET, shemminger@vyatta.com wrote:
>> >> >On Wed, 12 Dec 2012 19:10:17 +0100
>> >> >Jiri Pirko <jiri@resnulli.us> wrote:
>> >> >
>> >> >> ># ip li show dev dummy0
>> >> >> >12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500=
 qdisc noqueue state DORMANT mode DORMANT  =20
>> >> >>=20
>> >> >> if you mean this "NO-CARRIER"
>> >> >> it has no direct relation with netif_carrier_ok().
>> >> >
>> >> >It is the same value (IFF_RUNNING) that is visible from user spa=
ce.
>> >>=20
>> >> static inline bool netif_carrier_ok(const struct net_device *dev)
>> >> {
>> >> 	        return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
>> >> }
>> >>=20
>> >> So netif_carrier[ok/on/off] are working with on __LINK_STATE_NOCA=
RRIER
>> >> bit. Not with IFF_RUNNING flag.
>> >
>> >What is the code path that you are worried about netif_carrier_ok b=
eing set or clear?
>> >The interaction here is complex, and right now LINK_STATE_NOCARRIER=
 is purely
>> >controlled by the driver, your patch changes that, but before ackin=
g I want
>> >to make sure why it is required.
>>=20
>> This patchset would provide a possibility to set or clear the carrie=
r
>> from userspace. For dummy device it would serve for direct emulation
>> of link fail.
>>=20
>> Also for team deriver, that would serve for teamd (userspace part) t=
o
>> set the carrier actually on or off (in case of LACP runner for examp=
le
>> this is required).
>>=20
>
>You want to able to control the dummy device, so that you can test car=
rier
>management in the team device. Another alternative is to use carrier c=
ontrol
>on a virtual device. Vmware can do it, there were patches to do this w=
ith KVM/QEMU
>not sure if they ever got incorporated.
>
>Since this is a specific feature of the dummy device which is speciali=
zed for
>testing, maybe it should just be done by adding device specific ioctl =
rather
>than letting it creep in as a general facility.

Ugh, specific ioctl stinks...
But this is not only for dummy. As I said, we need this for team driver=
=2E
Maybe I did not explain that correctly. Given the fact that the whole
Team logic is in userspace, teamd (userspace daemon) needs to set the
carrier state as if it was done in kernel. Yes, we would be able to do
this by specific Team option in team driver, but I thought this would b=
e
nicer to do that more generally.

Also, in previous discussion Micha=C5=82 Miros=C5=82aw wrote he would l=
ike this
feature also for GRE tunnel devices.
