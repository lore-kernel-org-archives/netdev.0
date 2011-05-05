From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv4 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Thu, 5 May 2011 20:35:42 +0200
Message-ID: <BANLkTikJ67YLGzR-3rjazkUgmffMxp1nJQ@mail.gmail.com>
References: <1304471935-402-3-git-send-email-maheshb@google.com>
 <1304559247-16111-1-git-send-email-maheshb@google.com> <BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
 <BANLkTin88L+YBrpdaHR57CSx3dg2dMF7Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:64748 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab1EESgC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:36:02 -0400
Received: by qyk7 with SMTP id 7so3744657qyk.19
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 11:36:02 -0700 (PDT)
In-Reply-To: <BANLkTin88L+YBrpdaHR57CSx3dg2dMF7Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 5 maja 2011 19:47 u=BFytkownik Mahesh Bandewar
<maheshb@google.com> napisa=B3:
> On Wed, May 4, 2011 at 11:59 PM, Micha=B3 Miros=B3aw <mirqus@gmail.co=
m> wrote:
>> 2011/5/5 Mahesh Bandewar <maheshb@google.com>:
>>> This patch adds tg3_set_features() to handle loopback mode. Current=
ly the
>>> capability is added for the devices which support internal MAC loop=
back mode.
>>> So when enabled, it enables internal-MAC loopback.
[...]
>>> @@ -9485,6 +9533,15 @@ static int tg3_open(struct net_device *dev)
>>>
>>> =A0 =A0 =A0 =A0netif_tx_start_all_queues(dev);
>>>
>>> + =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0* Reset loopback feature if it was turned on while=
 the device was down
>>> + =A0 =A0 =A0 =A0* to avoid and any discrepancy in features reporti=
ng.
>>> + =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 if (dev->features & NETIF_F_LOOPBACK) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features &=3D ~NETIF_F_LOOPBACK;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->wanted_features &=3D ~NETIF_F_LO=
OPBACK;
>>> + =A0 =A0 =A0 }
>>> +
>>
>> if (dev->features & NETIF_F_LOOPBACK)
>> =A0tg3_set_loopback(dev, dev->features);
>>
> Unfortunately at this stage device will not be able to set-loopback s=
o
> I resorted to clearing the bit(s).

ndo_fix_features+ndo_set_features might be caled before ndo_open - the
first might be just from register_netdev() so even before ndo_open
callback.

>> Whatever you do, don't modify wanted_features in drivers.
> Since just clearing the 'features' would leave wanted_features in
> discrepant state, I thought this will bring it to a sane state. So
> what is a preferred way?

If you really can't do other way, driver should keep additional state
that is checked in ndo_fix_features callback.

>> BTW, similar problems (also like in previous versions) are in
>> forcedeth implementation.
> Yes, whatever we decide about the state of the wanted_features, I'll
> implement similarly for forcedeth. Which previous problem you are
> referring to? Is it the return value? There is a different kind of
> failure (error while writing the register). Since update_features()
> cant handle return value, I'm ignoring the return value. As far as th=
e
> correct return code is concerned, I wasn't sure what is appropriate
> return code here (may be PHY_ERROR would be appropriate there) but
> again I could ignore it just the way rest of the code is ignoring.

Let's wait for this threads points to be resolved. You will probably
change the forcedeth's implementation then anyway. :-)

Best Regards,
Micha=B3 Miros=B3aw
