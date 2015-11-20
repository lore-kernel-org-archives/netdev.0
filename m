From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Kernel 4.1.12 crash
Date: Fri, 20 Nov 2015 15:13:08 -0800
Message-ID: <564FA904.7020603@gmail.com>
References: <564F26FF.3040605@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew <nitr0@seti.kr.ua>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33495 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbKTXNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 18:13:10 -0500
Received: by pabfh17 with SMTP id fh17so133666098pab.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 15:13:09 -0800 (PST)
In-Reply-To: <564F26FF.3040605@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2015 05:58 AM, Andrew wrote:
> Hi all.
>
> Today some BRASes on 4.1.12 kernel were crashed.
>
> Here's crash traces: http://pastebin.com/p68hNS8R
> http://pastebin.com/36ieRAM2 http://pastebin.com/3BRTVEB6
>
> On 3.2 kernel same hardware works OK, troubles were noticed after kernel
> upgrade.
>
> What additional info is needed?

Looking over the traces there seem to be two areas called out.

The first is the fib_trie resize BUG_ON that was triggered due to the 
parent and child not being associated.  I think that might be due to 
memory corruption as I cannot find any spots where we are resizing 
without correctly setting up the parent-child relationship of the nodes 
first.

The other spot that is showing up is ppp_shutdown_interface and it's 
related path.  It looks like there are a couple of patches you could try 
back-porting to see if it resolves the issue.  If they do then perhaps 
they should be considered candidates for stable:

8cb775bc0a3 ("ppp: fix device unregistration upon netns deletion")
58a89ecaca5 ("ppp: fix lockdep splat in ppp_dev_uninit()")

- Alex
