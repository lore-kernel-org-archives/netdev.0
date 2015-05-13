From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net v3] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Wed, 13 May 2015 10:43:08 -0400
Message-ID: <20150513144305.GF9559@gospo.home.greyhouse.net>
References: <555216DA.3020105@6wind.com>
 <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150512155842.GA2081@nanopsycho>
 <20150512171248.GD9559@gospo.home.greyhouse.net>
 <55533D01.6070207@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36858 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965207AbbEMOnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 10:43:13 -0400
Received: by oift201 with SMTP id t201so32779935oif.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 07:43:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55533D01.6070207@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 02:01:05PM +0200, Nicolas Dichtel wrote:
> Le 12/05/2015 19:12, Andy Gospodarek a =E9crit :
> >On Tue, May 12, 2015 at 05:58:42PM +0200, Jiri Pirko wrote:
> >>Tue, May 12, 2015 at 05:17:45PM CEST, nicolas.dichtel@6wind.com wro=
te:
> [snip]
> >>>First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
> >>>d4261e565000 says that it was put only to notify userspace). Hence=
, we can
> >>>call directly rtmsg_ifinfo().
> >>
> >>Please leave this notifier here. Will be needed in very near future=
 for
> >>LAG offloading purposes.
> >
> >I agree with this.  It is extremely useful for a variety of reasons =
(not
> >just the offload case), so please to do not remove it.
> No problem, I will keep it.
>=20
> For my knowledge, can you explain these "variety of reasons"?

I maybe 'variety' was too strong of a word.  :)

The offload case has uses for it in the future as well as the case wher=
e
userspace deamons who are not sending the netlink message but are
monitoring netlink messages as a way to track port status.  Deamons tha=
t
would help broker multi-host LAGs are one such example. =20

Though it does look like the only event that will happen when
NETDEV_CHANGEINFODATA is called is an RTM_NEWLINK, it will get used mor=
e
in the future, so please keep it.
