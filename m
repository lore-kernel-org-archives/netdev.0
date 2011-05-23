From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Sun, 22 May 2011 19:02:43 -0700
Message-ID: <m1y61yb2d8.fsf@fess.ebiederm.org>
References: <20110521093936.GA3015@p183> <m11uzsxdty.fsf@fess.ebiederm.org>
	<20110521223054.GA3198@p183> <m1vcx3r3o5.fsf@fess.ebiederm.org>
	<20110523014303.GA2351982@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35026 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1EWCCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 22:02:55 -0400
In-Reply-To: <20110523014303.GA2351982@jupiter.n2.diac24.net> (David
	Lamparter's message of "Mon, 23 May 2011 03:43:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter <equinox@diac24.net> writes:

>> ... Eric W. Biederman wrote:
>> Now it probably needs to be better documented that /proc/*/net/*
>> have the same inode number if the network namespace is the
>> same, as everyone including myself overlooked this very handy
>> existing property.
>
> Eh, so did I. But, yes, very nice.
>
> On Sat, May 21, 2011 at 05:15:38PM -0700, Eric W. Biederman wrote:
>> Additionally that solution will work for comparing network namespaces
>> that don't happen to have any processes in them at the moment.  Because
>> fstat works on file descriptors.
>
> Hm. I have a peeve here. Assume I am a... rogue admin, whatever. I have
> root on a router. I create a new network namespace, put a macvlan of
> eth0 in it and a macvlan of eth1. I enable ip_forward.
>
> Then I make a mount namespace, bind-mount the net namespace, bind mount
> the mount namespace and terminate all processes that reference it (yes
> this does work, i just checked [!]).

You must be using an older version of my patchset than what I have
queued for Linus.  Bind mounting the mount namepsace and creating
reference counting loops is a weird and ugly case.  So for the moment I
am not supporting the mount namespace, until I can think through
the consequences.

> Now I can use it to bypass all firewall rules, IDS, whatever.
>
> How is any normal admin, monitoring script or whatever else able to
> detect this?

Which is why we I proceed slowly and cautiously with adding new kernel
interfaces.  It is hard to think of everything until you can actually
put it into use, and play with it.

Other than not allowing bind mounting the mount namespace I don't
have any all encompassing really good answers at the moment.

I do have a few small answers.  For network namespaces you can look in
/proc/slabinfo and see how many you have, unless slub is lying to you.
On the switch your server is connected to you can look at the mac table
and see which mac addresses are currently in use, and notice if there
are unaccounted for mac addresses.

Eric
