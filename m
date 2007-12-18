From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [ROSE] [AX25] possible circular locking
Date: Tue, 18 Dec 2007 23:04:10 +0100
Message-ID: <20071218220410.GA15502@ami.dom.local>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local> <476837BF.3070207@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pidoux <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:21551 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513AbXLRWBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 17:01:08 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1472333nfb.21
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 14:01:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <476837BF.3070207@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 18, 2007 at 10:12:31PM +0100, Pidoux wrote:
> Hi,
>
> Thank you Jarek for the analysis of the circular locking dependency report.
> I applied the patch you proposed and it works well as soon as I am able to 
> reboot now without
> lock warning message and I can also killall kissattach.
>
> I tried also the patch without the loop, that is only spin_unlock_bh() 
> before calling
> ax25_disconnect() and spin_lock_bh() just after.
> It worked also well.
> However I must say that I only have one ax25 device running (ax0).
>
> Is the loop really necessary here ? in case there are more than one ax25 
> device ?
>
> Also, I will let my AX25 - ROSE application running in order to test the 
> system stability with the full patch.
> I will let you know the results in a while.

Thank you Bernard for the bravery!

The loop is only for debugging: I don't know exactly what is done
during this ax25_disconnect(), and how the list can change in the
meantime because of some other activities. So, it's e.g. against
possible list_del of this node - then some sockets would stay not
disconnected.

I think, it's up to Ralf or some other ax25 expert to judge if this
could be done like this. Since it's not used very often, I think
this should better stay during testing: if there are no warnings
- the loop isn't repeated; otherwise it could simply take a little
more time, but all sockets should be serviced, plus we know about
problems.

Thanks,
Jarek P.
