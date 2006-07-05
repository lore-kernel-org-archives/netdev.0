From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 rx error problems...
Date: Wed, 5 Jul 2006 12:44:58 +0100
Message-ID: <6278d2220607050444o680ac35dn68e2fd0adb918812@mail.gmail.com>
References: <6278d2220605301408g646fc01l49a8713763cdc009@mail.gmail.com>
	 <20060530161714.4420e9b4@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netfilter Developer" <netfilter-devel@lists.netfilter.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:56995 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S964820AbWGELpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 07:45:32 -0400
Received: by py-out-1112.google.com with SMTP id t32so2177892pyc
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2006 04:44:58 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060530161714.4420e9b4@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Sorry to bring you more trouble. I'm able to reproduce this 'status
0x977d977d' rx race even with a 100Mb FD connection (MTU 1500) to the
host sending the data.

Would it help if I try and capture some packet stats or a dump of
this? The packets being received at the sending host will be a steady
stream of TCP acks and SMB protocol acks (every 64KB of data), so not
too heavy. The sending host has a Pentium-M 1.7GHz with 2MB L2$ and is
quiescent apart from samba sending data via sendfile(), so is
relatively powerful.

Let me know if there is anything I can do to help.

Many thanks,
  Daniel

On 31/05/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Tue, 30 May 2006 22:08:12 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>
> > To follow on from the previous 'sky2 rx error' problem reported, the
> > problem doesn't have anything to do with iptables or MTU settings, ie
> > can be reproduced out the box.
> >
> > The race is hit after a couple of GBs of data. Initially, I thought
> > this may have something to do with broken MSI support on my Intel
> > ICH-7M chipset, but disabling MSI didn't help.
> >
> > kernel: sky2 lan0: rx error, status 0x977d977d length 0
> >
> > Is there any debug information I can get to help or such? Voluntary
> > preemption is enabled, UP, HZ=100 on 2.6.17-rc4 on i686.
> >
> > Dan
>
> No the problem is your CPU isn't keeping up with the incoming flood
> and what ever you are connected to doesn't do hardware flow control.
> The driver doesn't properly flush the FIFO (yet), and it is not clear
> even from the NDA documentation the steps required.
-- 
Daniel J Blueman
