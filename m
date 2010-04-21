From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in netns  thread
Date: Wed, 21 Apr 2010 12:36:07 -0700
Message-ID: <m1ljcgzjh4.fsf@fess.ebiederm.org>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
	<1271612005.3679.248.camel@localhost>
	<o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 577640@bugs.debian.org,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43701 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610Ab0DUTgQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:36:16 -0400
In-Reply-To: <o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
 (=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Wed\, 21 Apr 2010
 17\:19\:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:

> I'm not starting a new thread/bug, as this is probably related...
>
> I just discovered that in 2.6.33, if I create a veth inside a
> namespace and then move one of the halves into the main namespace,
> when I kill the namespace, I get one of these warnings followed by an
> oops. This does not happen if the veth is created from the main ns an=
d
> then moved, nor in 2.6.32. This happens both in Qemu and on real
> hardware (both amd64)
>
> To reproduce:
>
> $ sudo ./startns bash
> # ip l a type veth
> # ip l s veth0 netns 1
> # exit

Nasty weird. I did a quick test here, and I'm not seeing that.
Does the 2.6.33 experimental kernel have any patches applied?

The sysfs_add_one path looks like someone we hit a duplicate name,
which is a bug of an entirely different kind.  From there it appears
that we later destroy the device not realizing it isn't in sysfs.
Which causes everything to explode.

The sysctl issues appears to be that somewhere we have the ordering of
creates and/or deletes wrong.  It is just possible the changes for
batch deletion might be exposing a bug under load.

The sysctl error appears to be in the class of things that should never
happen but that we should handle correctly anyway.

Eric
