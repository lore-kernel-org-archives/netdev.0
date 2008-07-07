From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: setsockopt()
Date: Mon, 7 Jul 2008 14:33:06 -0700
Message-ID: <20080707143306.56dcdb2e@extreme>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jim Rees <rees@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47986 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454AbYGGVdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:33:08 -0400
In-Reply-To: <48728B09.1050801@citi.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Jul 2008 17:30:49 -0400
Olga Kornievskaia <aglo@citi.umich.edu> wrote:

> 
> 
> Stephen Hemminger wrote:
> > On Mon, 07 Jul 2008 14:18:38 -0400
> > Olga Kornievskaia <aglo@citi.umich.edu> wrote:
> >
> >   
> >> Hi,
> >>
> >>     I'd like to ask a question regarding socket options, more 
> >> specifically send and receive buffer sizes.
> >>
> >>     One simple question: (on the server-side) is it true that, to set 
> >> send/receive buffer size, setsockopt() can only be called before 
> >> listen()? From what I can tell, if I were to set socket options for the 
> >> listening socket, they get inherited by the socket created during the 
> >> accept(). However, when I try to change send/receive buffer size for the 
> >> new socket, they take no affect.
> >>
> >>     The server in question is the NFSD server in the kernel. NFSD's code 
> >> tries to adjust the buffer size (in order to have TCP increase the 
> >> window size appropriately) but it does so after the new socket is 
> >> created. It leads to the fact that the TCP window doesn't open beyond 
> >> the TCP's "default" sysctl value (that would be the 2nd value in the 
> >> triple net.ipv4.tcp_rmem, which on our system is set to 64KB). We 
> >> changed the code so that setsockopt() is called for the listening socket 
> >> is created and we set the buffer sizes to something bigger, like 8MB. 
> >> Then we try to increase the buffer size for each socket created by the 
> >> accept() but what is seen on the network trace is that window size 
> >> doesn't open beyond the values used for the listening socket.
> >>     
> >
> > It would be better if NFSD stayed out of doign setsockopt and just
> > let the sender/receiver autotuning work?
> >   
> Auto-tuning would be guided by the sysctl values that are set for all 
> applications. I could be wrong but what I see is that unless an 
> application does a setsockopt(), its window is bound by the default 
> sysctl value. If it is true, than it is not acceptable. It means that in 
> order for NFSD to achieve a large enough window it needs to modify TCP's 
> sysctl value which will effect all other applications.
>

Auto tuning starts at the default and will expand to the max allowed.
If you set a value with setsockopt, then the kernel just uses that value
and does no tuning.
