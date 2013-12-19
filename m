From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 19 Dec 2013 17:28:10 +0100
Message-ID: <20131219162810.55810@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	"Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:61998 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab3LSQ2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 11:28:14 -0500
Received: from mailout-eu.gmx.com ([10.1.101.212]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MXCV1-1VyzX73o3B-00WC8z for
 <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:28:12 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only reason why i give information about 2.6.36.4 is that its the only latest kernel that was functioning properly.
i.e kernel >= 2.6.37 is not woking. so its a bisecting of the kernel versions to help a coder see when/where the isse was implemented in the kernel.

I do not need a backport patch for an old kernel, I generally only need the issue looked into and get fixed so that I dont have to use an old kernel. :)

I have no issue reproducing the issue on the recent kernels. however i have not tried the GIT kernel.

I restarted the server just a moment ago. i will install and run dropwatch and provide feedback in about 17hours. 

Thanks
----- Original Message -----
From: Hannes Frederic Sowa
Sent: 12/19/13 04:48 PM
To: Ben Greear
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
 On Thu, Dec 19, 2013 at 07:15:37AM -0800, Ben Greear wrote:
> On 12/19/2013 07:09 AM, Hannes Frederic Sowa wrote:
> >On Thu, Dec 19, 2013 at 03:48:16PM +0100, Bob Falken wrote:
> >>Hello, I have an issue after kernel 2.6.37 and above.
> >>If i roll back to kernel 2.6.36.4 everything is fine.
> >>if recive more than 4294967295 multicast packets, the kernel does not 
> >>register the multicast packets. and multicast routing does not 
> >>functioning.
> >>(Tested bouth FIB_HASH and FIB_TRIE)
> >>Tested with xorp and pimd.
> >>I have abount 24 multicast groups, and it takes me about 17hours to 
> >>reproduce the issue after a reboot.
> >>Reboot is reqired to fix the issue. (Tested to stop/start pimd/xorp, 
> >>reload network module for the network interface "e1000e",
> >>Used birdge adapter and remove bridge adapter and readd bridge adapter to 
> >>clear counters. none of thouse solves the issue.)
> >
> >Please test this with a recent kernel. 2.6.37 is really old and you 
> >normally
> >won't get good support here with such old kernels.
> 
> Note that he did test up to 3.11.9 and it still showed failures.

Oh sorry, I did not read to the end. ;)

An interesting hint could be to use dropwatch or perf script net_dropmonitor
to check where the fragments get dropped. Also nstat could give additional
hints where something might get wrong. Please use a recent kernel while
debugging this issue. Maybe a patch can get backported later.

Thanks,

 Hannes 
