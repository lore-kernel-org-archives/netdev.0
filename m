From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 4 May 2009 16:50:46 +0200
Message-ID: <20090504145046.GI23223@one.firstfloor.org>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <20090504094431.174745mb0jhhm3s4@www.nexusmail.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Elad Lahav <elahav@uwaterloo.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Elad Lahav <elahav@cs.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37889 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754367AbZEDOqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 10:46:12 -0400
Content-Disposition: inline
In-Reply-To: <20090504094431.174745mb0jhhm3s4@www.nexusmail.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 04, 2009 at 09:44:31AM -0400, Elad Lahav wrote:
> >My guess it's more the copies than the calls?
> It's a factor of both. This is why we also created the sendgroup()  
> implementation that uses a tight loop of in-kernel calls to sendmsg()  
> as a means for evaluating the cost of mode switches. It is definitely  
> not negligible (exact numbers depend on the size of the group and the  
> size of the payload, of course).

How much is non negligible in your case?

> 
> >It sounds like you want sendfile() for UDP.
> Do you mean by having a per-recipient sendfile() call for the same  
> file? Leaving the cost of the system call aside, this solution does  
> not work well with the kind of real-time data that we've been working  
> with (live streaming, online games). You would have to write the  
> payload to the file as it is being generated and call sendfile() after  
> each such write.

You can mmap the file.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
