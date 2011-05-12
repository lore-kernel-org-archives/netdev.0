From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv1] e1000e: Allow ethtool to enable/disable loopback.
Date: Thu, 12 May 2011 07:50:28 +0200
Message-ID: <BANLkTi=YbTgy0cNJRvcg1QkWCv9sNKkvUQ@mail.gmail.com>
References: <1305140625-25888-1-git-send-email-maheshb@google.com>
 <BANLkTikXbL2arWSYW1aPV02C8dDdHTUG6Q@mail.gmail.com> <BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:57890 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab1ELFus convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 01:50:48 -0400
Received: by qyk7 with SMTP id 7so2723058qyk.19
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 22:50:48 -0700 (PDT)
In-Reply-To: <BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 maja 2011 01:11 u=BFytkownik Mahesh Bandewar
<maheshb@google.com> napisa=B3:
> On Wed, May 11, 2011 at 12:15 PM, Micha=B3 Miros=B3aw <mirqus@gmail.c=
om> wrote:
>> 2011/5/11 Mahesh Bandewar <maheshb@google.com>:
>>> This patch adds e1000_set_features() to handle loopback mode. When =
loopback
>>> is enabled, it enables internal-MAC loopback.
>> Please wait for this driver's conversion to hw_features. One comment
>> below, though.
> This is not intrusive so should not create problems when that happens=
=2E

=46ine by me then.

>> [...]
>>> --- a/drivers/net/e1000e/netdev.c
>>> +++ b/drivers/net/e1000e/netdev.c
>> [...]
>>> +static int e1000_set_features(struct net_device *dev, u32 features=
)
>>> +{
>>> + =A0 =A0 =A0 u32 changed =3D dev->features ^ features;
>>> +
>>> + =A0 =A0 =A0 if ((changed & NETIF_F_LOOPBACK) && netif_running(dev=
))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 e1000_set_loopback(dev, features);
>>> +
>>> + =A0 =A0 =A0 return 0;
>>> +}
>> [...]
>>
>> If e1000_set_loopback() fails, this should set dev->features to pass=
ed
>> features (but keeping NETIF_F_LOOPBACK unchanged in dev->features) t=
o
>> keep the state consistent.
> set_features() can return the return code of set_loopback() instead o=
f
> 0; this way the consistency will be maintained.

Only as long as NETIF_F_LOOPBACK is the only bit set in hw_features.
netdev_update_features() can't really know which features were changed
and which failed when ndo_set_features callback returns non-zero.

Best Regards,
Micha=B3 Miros=B3aw
