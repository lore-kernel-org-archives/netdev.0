From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv1] e1000e: Allow ethtool to enable/disable loopback.
Date: Fri, 13 May 2011 09:49:35 +0200
Message-ID: <BANLkTi=W3M-P_0BXVJvZx25xUcy7bLiWEg@mail.gmail.com>
References: <1305140625-25888-1-git-send-email-maheshb@google.com>
 <BANLkTikXbL2arWSYW1aPV02C8dDdHTUG6Q@mail.gmail.com> <BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
 <BANLkTi=YbTgy0cNJRvcg1QkWCv9sNKkvUQ@mail.gmail.com> <BANLkTimsUga1LEF1y61+2To2uQQGpxcPBg@mail.gmail.com>
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
Received: from mail-qy0-f181.google.com ([209.85.216.181]:45793 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757109Ab1EMHt4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 03:49:56 -0400
Received: by qyg14 with SMTP id 14so1322734qyg.19
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 00:49:55 -0700 (PDT)
In-Reply-To: <BANLkTimsUga1LEF1y61+2To2uQQGpxcPBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 maja 2011 23:41 u=BFytkownik Mahesh Bandewar
<maheshb@google.com> napisa=B3:
> On Wed, May 11, 2011 at 10:50 PM, Micha=B3 Miros=B3aw <mirqus@gmail.c=
om> wrote:
>> W dniu 12 maja 2011 01:11 u=BFytkownik Mahesh Bandewar
>> <maheshb@google.com> napisa=B3:
>>> On Wed, May 11, 2011 at 12:15 PM, Micha=B3 Miros=B3aw <mirqus@gmail=
=2Ecom> wrote:
>>>> If e1000_set_loopback() fails, this should set dev->features to pa=
ssed
>>>> features (but keeping NETIF_F_LOOPBACK unchanged in dev->features)=
 to
>>>> keep the state consistent.
>>> set_features() can return the return code of set_loopback() instead=
 of
>>> 0; this way the consistency will be maintained.
>> Only as long as NETIF_F_LOOPBACK is the only bit set in hw_features.
>> netdev_update_features() can't really know which features were chang=
ed
>> and which failed when ndo_set_features callback returns non-zero.
> This is more of an API shortcoming. Callback will have to revert
> changes made (rollback) before returning non-zero value to keep it
> consistent.

It might just update dev->features to match instead of rollback. It
could also start some recovery process that eventually calls
netdev_update_features() again to try the change again.

IOW, the information what changes failed are returned implicitly in
modified dev->features. When callback returns 0,
netdev_update_features() assumes that all were set correctly and
updates dev->features itself.

Best Regards,
Micha=B3 Miros=B3aw
