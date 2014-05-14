From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Problem with iflink in netns
Date: Wed, 14 May 2014 10:23:13 +0200
Message-ID: <537327F1.4060603@6wind.com>
References: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:63645 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaENIXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 04:23:16 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so1544045wgg.30
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 01:23:15 -0700 (PDT)
In-Reply-To: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/05/2014 17:39, Stephen Hemminger a =E9crit :
> There have been a couple of bugzilla reports already about cases wher=
e a macvlan
> or vlan is moved into another namespace. In these cases the parent de=
vice ifindex (iflink)
> is no longer valid.
>
>
> Normally it is not a big issue, until another device is created using=
 the ifindex
> of the parent
>
> Does anyone have a suggested fix? Marking iflink as 0 won't work then=
 the devices no
> longer appear as slaves. Another possibility would be to make block c=
reation of device
> where ifindex matches existing iflink of other devices; but this woul=
d slow down device
> creation.
The problem is that we to add an information about the netns where the =
ifindex
stands, we can currently use only a pid or a file descriptor, hence it'=
s not
possible to broadcast this information. The advantage of the file descr=
iptor is
that it's a local id not a global one.

On idea I'm thinking is that each netns manages its own set of UID for =
peer
netns, this means that these UID will be valid only in a spcecified net=
ns.
We may add a netlink message to help the user to associate an UID with =
a file
descriptor/pid (he gives the file descriptor/pid and the kernel returns=
 the
UID).
These UID may be generated only the user requests them or when the kern=
el sends
an information about a peer netns.
These UID will be provided in existing netlink message in a separate ne=
tlink
attribute.

If the idea is ok, I can help to work on this topic.


Regards,
Nicolas
>
>
> The bugs come in as ip command bugs, but obviously the issue is in th=
e kernel.
>
> https://bugzilla.kernel.org/show_bug.cgi?id=3D66691
> https://bugzilla.kernel.org/show_bug.cgi?id=3D75911
