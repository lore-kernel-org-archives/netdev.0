From: kuznet@ms2.inr.ac.ru
Subject: Re: [patch] add iocb to network protocols
Date: Sat, 12 Oct 2002 00:15:48 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210112015.AAA28278@sex.inr.ac.ru>
References: <20021010194025.B13432@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.COM (Benjamin LaHaise)
In-Reply-To: <20021010194025.B13432@redhat.com> from "Benjamin LaHaise" at Oct 11, 2 04:15:01 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> The private area of an iocb for network operations contains a struct 
> scm_cookie.  The alternative is to allocate it via kmalloc when needed, 
> but there isn't currently a way of identifying which network protocols 
> require the scm_cookie.

Kill it. It was not killed in 2.4 by plain luck, sorry, misfortune.

However, I do not understand this. You need to pass forth and back
SCM_RIGHTS is some way. It is quite dubious to make this asynchronously.
The same is surely true about credentials, they should be latched
on entry, not at the moment of real execution.

Kill anyway, at least in synchronous calls this was my mistake.

Alexey
