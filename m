From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Sat, 9 May 2009 01:42:47 +0300
Message-ID: <200905090142.47250.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <200905090005.38712.denys@visp.net.lb> <20090508220727.GA26865@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35046 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbZEHWmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 18:42:50 -0400
In-Reply-To: <20090508220727.GA26865@francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 May 2009 01:07:27 Vladimir Ivashchenko wrote:
> > > Wow, instead of 98425b burst, its calculating 970203b.
> >
> > Kind of strange burst, something wrong there. For 1000HZ and 1 Gbit it
> > should be 126375b. You value is for 8Gbit/s.
> > What version of iproute2 you are using ( tc -V )?
>
> That was iproute2-ss080725, I think it is confused by tickless mode.
> With iproute2-ss090324 I'm getting an opposite: 1589b :)
And it is too low. Thats why i set HZ=1000
>
>
> All child classes have smaller bursts than the parent. However, there are
> two sub-classes which have ceil at 70% of parent, e.g. ~500mbit each. I
> don't know HTB internals, perhaps these two classes make the parent class
> overstretch itself.
As i remember important to keep sum of child rates lower or equal parent rate.
Sure ceil of childs must not exceed ceil of parent.
Sometimes i had mess, when i tried to play with quantum value. After all that 
i switched to HFSC which works for me flawlessly. Maybe we should give more 
attention to HTB problem with high speeds and help kernel developers spot 
problem, if there is any.

>
> By the way, I experience the same "overstretching" with hfsc. In any case,
> I prefer HTB because it reports statistics of parent classes, unlike hfsc.
Sometimes it happen when some offloading enabled on devices.
Check ethtool -k device

I think everything except rx/tx checksumming have to be off, at least for 
test.

Disable them by "ethtool -K device tso off " for example.


>
> But why it would it jump from 850mbits to 1200mbits *AFTER* I remove all
> the traffic ?
>
Well, i dont know how it is doing averaging, even maybe for 1 minute. 
I dont like it at all, and thats why i prefer HFSC. But HTB work very well in 
some setups
