From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 00:55:57 +0200
Message-ID: <87ljy2tfgi.fsf@basil.nowhere.org>
References: <48C59F75.6030504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Christopher Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56387 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbYIHWz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 18:55:57 -0400
In-Reply-To: <48C59F75.6030504@redhat.com> (Christopher Snook's message of "Mon, 08 Sep 2008 17:56:05 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christopher Snook <csnook@redhat.com> writes:
>
> I'm afraid I don't know the TCP stack intimately enough to understand
> what side effects this might have.  Can someone more familiar with the
> nagle implementations please enlighten me on how this could be done,
> or why it shouldn't be?

The nagle delay you're seeing is really the delayed ack delay which
is variable on Linux (unlike a lot of other stacks). Unfortunately
due to the way delayed ack works on other stacks (especially traditional
BSD with its fixed 200ms delay) there are nasty interactions with that. 
Making it too short could lead to a lot more packets even in non nagle 
situations.

Ok in theory you could split the two, but that would likely have
other issues and also make nagle be a lot less useful.

-Andi

-- 
ak@linux.intel.com
