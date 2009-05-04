From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 4 May 2009 11:53:00 +0200
Message-ID: <20090504095300.GF23223@one.firstfloor.org>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <49FE9999.7090103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Elad Lahav <elahav@uwaterloo.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58947 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbZEDJs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 05:48:26 -0400
Content-Disposition: inline
In-Reply-To: <49FE9999.7090103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >My guess it's more the copies than the calls? It sounds like
> >you want sendfile() for UDP. I think that would be a cleaner solution
> >than such a specific hack for your application. It would
> >have the advantage of saving the first copy too and be 
> >truly zero copy on capable NICs.
> >  
> 
> An aio udp send could accomplish both multiple packets per call, and 

AIO sockets are a lot of work. There have been various attempts
over the years, but they are very difficult. This was mostly
for TCP -- possibly UDP would be a bit easier -- but still
many complications. It would also need a lot of changes and
you would need to convince the network maintainers that they
are a good idea.

> >Or perhaps simple send to a local multicast group and let
> >some netfilter module turn that into regular UDP.
> >  
> 
> Sounds hacky and rooty.

rooty? Everyone can send to all directions anyways.

It wouldn't be perfect, but quite usable as a short term solution
for a production server.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
