From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Avoid signal race in arpd initialization.
Date: Sun, 15 Mar 2015 12:25:15 -0700
Message-ID: <20150315122515.1a164175@urahara>
References: <20150311205845.GA23722@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tobias Stoeckmann <tobias@stoeckmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34655 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbCOTZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:25:19 -0400
Received: by pdbni2 with SMTP id ni2so36926450pdb.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:25:18 -0700 (PDT)
In-Reply-To: <20150311205845.GA23722@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Mar 2015 21:58:45 +0100
Tobias Stoeckmann <tobias@stoeckmann.org> wrote:

> Signal handlers in arpd use siglongjmp() to return into main function
> during polls. The environment for the jumps is set after the signal
> handlers are installed. This leaves a small time frame in which an
> uninitialized environment could be used for a siglongjmp() call, leading
> to undefined behavior.
> 
> While at it, define flag variables as sig_atomic_t instead of int.

I understand, but this is such a corner case. And you made several
other changes. Don't think it is worth doing this change.

You would have to signal arpd in the very small window between
the signal setup and the setjmp call.
