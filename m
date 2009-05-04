From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 09:13:10 +0200
Message-ID: <87eiv5ibnd.fsf@basil.nowhere.org>
References: <49FE47A1.7070700@uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Elad Lahav <elahav@uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39632 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbZEDHNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 03:13:16 -0400
In-Reply-To: <49FE47A1.7070700@uwaterloo.ca> (Elad Lahav's message of "Sun, 03 May 2009 21:40:49 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Elad Lahav <elahav@uwaterloo.ca> writes:

> The attached patch contains an implementation of sendgroup(), a system
> call that allows a UDP packet to be transmitted efficiently to
> multiple recipients. Use cases for this system call include
> live-streaming and multi-player online games.
> The basic idea is that the caller maintains a group - a list of IP
> addresses and UDP ports - and calls sendgroup() with the group list
> and a common payload. Optionally, the call allows for per-recipient
> data to be prepended or appended to the shared block. The data is
> copied once in the kernel into an allocated page, and the
> per-recipient socket buffers point to that page. Savings come from
> avoiding both the multiple calls and the multiple copies of the data
> required with regular socket operations.

My guess it's more the copies than the calls? It sounds like
you want sendfile() for UDP. I think that would be a cleaner solution
than such a specific hack for your application. It would
have the advantage of saving the first copy too and be 
truly zero copy on capable NICs.

Or perhaps simple send to a local multicast group and let
some netfilter module turn that into regular UDP.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
