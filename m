From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv1] e1000e: Allow ethtool to enable/disable
	loopback.
Date: Thu, 12 May 2011 14:41:55 -0700
Message-ID: <BANLkTimsUga1LEF1y61+2To2uQQGpxcPBg@mail.gmail.com>
References: <1305140625-25888-1-git-send-email-maheshb@google.com>
	<BANLkTikXbL2arWSYW1aPV02C8dDdHTUG6Q@mail.gmail.com>
	<BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
	<BANLkTi=YbTgy0cNJRvcg1QkWCv9sNKkvUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <BANLkTi=YbTgy0cNJRvcg1QkWCv9sNKkvUQ@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, May 11, 2011 at 10:50 PM, Micha=B3 Miros=B3aw <mirqus@gmail.com> wr=
ote:
> W dniu 12 maja 2011 01:11 u=BFytkownik Mahesh Bandewar
> <maheshb@google.com> napisa=B3:
>> On Wed, May 11, 2011 at 12:15 PM, Micha=B3 Miros=B3aw <mirqus@gmail.com>=
 wrote:
>>> 2011/5/11 Mahesh Bandewar <maheshb@google.com>:
>>>> This patch adds e1000_set_features() to handle loopback mode. When loo=
pback
>>>> is enabled, it enables internal-MAC loopback.
>>> Please wait for this driver's conversion to hw_features. One comment
>>> below, though.
>> This is not intrusive so should not create problems when that happens.
>
> Fine by me then.
>
>>> [...]
>>>> --- a/drivers/net/e1000e/netdev.c
>>>> +++ b/drivers/net/e1000e/netdev.c
>>> [...]
>>>> +static int e1000_set_features(struct net_device *dev, u32 features)
>>>> +{
>>>> + =A0 =A0 =A0 u32 changed =3D dev->features ^ features;
>>>> +
>>>> + =A0 =A0 =A0 if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 e1000_set_loopback(dev, features);
>>>> +
>>>> + =A0 =A0 =A0 return 0;
>>>> +}
>>> [...]
>>>
>>> If e1000_set_loopback() fails, this should set dev->features to passed
>>> features (but keeping NETIF_F_LOOPBACK unchanged in dev->features) to
>>> keep the state consistent.
>> set_features() can return the return code of set_loopback() instead of
>> 0; this way the consistency will be maintained.
>
> Only as long as NETIF_F_LOOPBACK is the only bit set in hw_features.
> netdev_update_features() can't really know which features were changed
> and which failed when ndo_set_features callback returns non-zero.
>
This is more of an API shortcoming. Callback will have to revert
changes made (rollback) before returning non-zero value to keep it
consistent.

Thanks,
--mahesh..

> Best Regards,
> Micha=B3 Miros=B3aw
>

---------------------------------------------------------------------------=
---
Achieve unprecedented app performance and reliability
What every C/C++ and Fortran developer should know.
Learn how Intel has extended the reach of its next-generation tools
to help boost performance applications - inlcuding clusters.
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
