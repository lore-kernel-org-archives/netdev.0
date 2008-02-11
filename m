From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Execute tasklets in the same order they were queued
Date: Mon, 11 Feb 2008 14:49:27 -0800
Message-ID: <20080211144927.55920e56.akpm@linux-foundation.org>
References: <20080211222813.GA14316@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40033 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753330AbYBKWu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:50:27 -0500
In-Reply-To: <20080211222813.GA14316@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Feb 2008 16:28:13 -0600
Olof Johansson <olof@lixom.net> wrote:

> I noticed this when looking at an openswan issue. Openswan (ab?)uses
> the tasklet API to defer processing of packets in some situations,
> with one packet per tasklet_action(). I started noticing sequences of
> reverse-ordered sequence numbers coming over the wire, since new tasklets
> are always queued at the head of the list but processed sequentially.
> 
> Convert it to instead append new entries to the tail of the list. As an
> extra bonus, the splicing code in takeover_tasklets() no longer has to
> iterate over the list.
> 

hm, I'd have thought that this would already have caused problems in
networking.  And perhaps this change might have effects on networking too?

Probably it won't have _much_ effect on networking because networking
probably isn't queueing one tasklet per packet(!) but perhaps with bonded
channels or something like that?

