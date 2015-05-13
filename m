From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: fix a possible leak issue of neigh entry
Date: Wed, 13 May 2015 06:07:10 -0700
Message-ID: <1431522430.566.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495814-22759-1-git-send-email-ying.xue@windriver.com>
	 <1431498048.566.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5552FC4D.3060200@windriver.com> <55532845.8010709@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33235 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933852AbbEMNHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:07:12 -0400
Received: by pacwv17 with SMTP id wv17so50447436pac.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 06:07:12 -0700 (PDT)
In-Reply-To: <55532845.8010709@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 18:32 +0800, Ying Xue wrote:
> On 05/13/2015 03:25 PM, Ying Xue wrote:
> > On 05/13/2015 02:20 PM, Eric Dumazet wrote:
> >> Have you hit this condition ?
> >>
> > 
> > No, I just found the issue when I was reading the code.
> > 
> >> If yes, there is a bug elsewhere and we need to fix it, not trying to
> >> recover.
> >>
> 
> After a search, it's found your mentioned bug probably should be:
> 
> https://patchwork.ozlabs.org/patch/458112/
> 
> But I think the bug should be a different issue that the patch is to be
> resolved. When the bug happened, neigh_add_timer() would take a reference on an
> object that already had a refcount of zero, which means somebody already
> decreased the refcount to zero before neigh_add_timer() was called. So, the bug
> should be unrelated to neigh_add_timer() although the bug really needs to be
> fixed. But the issue the patch tries to fix is wrong because it obviously
> violates the generic usage of how to take an object refcount in the object's
> timer handler as well as when its timer is started or deleted. Specially when a
> neighbour's timer to be modified is in pending state, we should not take its
> refcount, otherwise, the neighbour is leaked forever.
> 
> Therefore, the patch is needed for us even if your mentioned bug is not fixed.

Sorry, your patch is wrong.

As I said, if the issue is there, a different fix is needed.

Caller of the function must owns a refcount by definition.
