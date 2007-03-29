From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: netpoll question
Date: Wed, 28 Mar 2007 20:00:33 -0500
Message-ID: <1175130033.28767.19.camel@stevo-laptop>
References: <1175119380.28767.4.camel@stevo-laptop>
	 <460AFA3B.6090009@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:49941 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934287AbXC2BAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 21:00:35 -0400
In-Reply-To: <460AFA3B.6090009@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-28 at 16:28 -0700, Mark Huth wrote:
> Steve Wise wrote:
> > Hey all,
> >
> > I have netpoll question.  How does netpoll work with MSI/X, NAPI, and
> > nics that setup multiple RSS style receive queues for a single port?
> > >From what I can tell, if you're doing something like netdump using
> > netpoll for IO, then you might never process incoming packets that get
> > posted to the rx queues not associated with the main netdevice structure
> > because netpoll only calls the poll() function for the main netdev
> > struct.  Not the dummy netdevs setup for multiple rx queues.  
> >
> > Is this the case or am I confused?
> >
> > Thanks,
> >
> >
> > Steve
> You are correct.  Netpoll needs a bit of work, especially on the receive 
> side, for multi-queue and some other possible problems related to taking 
> locks when the system is frozen.  If I get some time soon, I'm going to 
> propose an overhaul to address some of these issues that show up in the 
> kgdboe and netdump cases.
> 
> Mark Huth

Hey Mark,

What are your thoughts on how to implement this?  

Scrub every softnet_data queue->poll_list for every cpu?  Or perhaps its
better to have a new function ptr off the netdev that sez "poll all rx
queues"?


Steve.


