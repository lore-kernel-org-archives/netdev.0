From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: e1000: Detected Tx Unit Hang
Date: Sat, 16 Feb 2008 01:26:42 +0100
Message-ID: <200802160126.43069.bernd-schubert@gmx.de>
References: <fp553k$9r8$1@ger.gmane.org> <47B6204D.8060503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58398 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751122AbYBPA0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 19:26:47 -0500
In-Reply-To: <47B6204D.8060503@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 16 February 2008, Kok, Auke wrote:
> Bernd Schubert wrote:
> > Hello,
> >
> > I can't login to one of our servers and just got this in an ipmi sol
> > session:
> >
> > [18169.209181] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [18169.209183]   Tx Queue             <0>
> > [18169.209184]   TDH                  <e3>
> > [18169.209185]   TDT                  <e3>
> > [18169.209186]   next_to_use          <e3>
> > [18169.209187]   next_to_clean        <bd>
> > [18169.209188] buffer_info[next_to_clean]
> > [18169.209189]   time_stamp           <10043e4d2>
> > [18169.209190]   next_to_watch        <be>
> > [18169.209191]   jiffies              <10043e6f6>
> > [18169.209192]   next_to_watch.status <1>
> > [18169.256978] e1000: eth2: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [18169.256979]   Tx Queue             <0>
> > [18169.256980]   TDH                  <de>
> > [18169.256982]   TDT                  <de>
> > [18169.256983]   next_to_use          <de>
> > [18169.256984]   next_to_clean        <bc>
> > [18169.256985] buffer_info[next_to_clean]
> > [18169.256986]   time_stamp           <10043e511>
> > [18169.256987]   next_to_watch        <bd>
> > [18169.256988]   jiffies              <10043e701>
> > [18169.256989]   next_to_watch.status <1>
> >
> > This is with 2.6.22.18. Is there any chance to recover the system? For
> > some reasons I would prefer not to reboot now.
>
> if that's all you have then it was false alarm. there should be a 'netdev
> timeout - link reset' following those messages. can you send some more
> context on those messages?

All I presently know is that there are 20 servers and login doesn't work any 
more - sysrq+t does show me it hangs in fuse, which is accessing the 
underlying nfs (we are using unionfs-fuse). While I checked the sysrq-t 
output suddenly these e1000 messages appeared.
Thinking a bit about it, it either could be 2.6.22.18 has an e1000 bug, which 
2.6.22.X didn't have (X=16, I think, but I'm not sure) or someone  
mis-configured the switch/network environment today. 
Hmm, now that I think about the last part, there already had been other 
networking problems today, which were supposed to be fixed several hours ago. 
Seems they didn't fix it properly.

>
> in real tx hang cases, the hardware is reset within 2 seconds, and
> everything continues as normal.

Thanks, this gives me hope I don't need to reboot the serves (reboot would 
mean I would need to start 60 md-raid rebuilds...).

Thanks,
Bernd
