From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] macvlan: add tap device backend
Date: Mon, 14 Dec 2009 16:40:13 +0100
Message-ID: <200912141640.13562.arnd@arndb.de>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de> <1259862720-28432-3-git-send-email-arnd@arndb.de> <4B26353A.9020005@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"" <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:60054 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbZLNPkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 10:40:55 -0500
In-Reply-To: <4B26353A.9020005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 December 2009, Patrick McHardy wrote:
> > +     classdev = device_create(macvtap_class, &dev->dev, devt,
> > +                              dev, "tap%d", dev->ifindex);
> > +     if (IS_ERR(classdev)) {
> > +             err = PTR_ERR(classdev);
> > +             macvtap_del_queues(dev);
> > +             macvlan_dellink(dev, NULL);
> 
> I think this may cause a double free since macvlan_dellink() will
> free the device and rtnl_newlink() will free it again on error.

Ah, right. I've changed this part a few times now, but I think introduced
the same bug again in the current version. I'll send out what I have now
if you want to take another look.

	Arnd
