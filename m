From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 08:05:23 -0700
Message-ID: <r3n61ibkk3w.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
	<87lhr77mwx.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, brandon.carpenter@pnnl.gov,
	casey@schaufler-ca.com, netdev@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <87lhr77mwx.fsf@synack.fr> (Samir Bellabes's message of "Sat\, 02
	Aug 2014 02\:30\:54 +0200")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Sam

> snet is more like a framework now.
> you can interactively register which syscall you want to monitor.
> then kernel substem will sent you informations.
> unregister, and the kernel subsystem is going quiet.
>
> in order to build your process tree, you just use the userspace lib (I
> don't think it is yet publicly available, I have to put this up-to-date
> too) 
>
> the lib is build on the same libpcap callback mecanism : you register a
> syscall with a callback function. your callback function is called to
> manage the informations every time the related syscall occured.
> Here you can build your process tree, or do whatever you want. 
>
> Now, kernel subsystem doesn't required always a userspace verdict, as
> there is a "monitor mode", which is exactly what you will use if you
> decide to use snet.
>
> As I said, snet is more like a framework to push this valuable
> informations to userspace, do whatever you want, and send back your
> policy decision (if it needs one) 

It sounds at least in theory like snet can do what I'm looking for. I
have a few concerns however:

 * since I'm trying to tie individual packets to processes, I think that
   would mean that I'd have to register for socket_sendmsg/socket_recvmsg.
   Would that mean a trip to userspace (for the bpf callback at least if
   this is just in monitor mode) for every packet?

 * obviously the current lsm hooks/attributes from snet.h don't account
   for tracking processes.

In any event, I'm interested in seeing the updated patchset/userspace
lib for registering/reading events.

Cheers
