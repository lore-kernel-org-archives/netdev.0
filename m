From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Thu, 05 Nov 2009 14:36:19 +0100
Message-ID: <4AF2D4D3.6060606@simula.no>
References: <52481f5b4edfdbd96dcde46aed403fcf.squirrel@webmail.uio.no> <4AEB109A.7090506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:44827 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073AbZKENgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 08:36:14 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N62Vf-0004oJ-DG
	for netdev@vger.kernel.org; Thu, 05 Nov 2009 14:36:19 +0100
In-Reply-To: <4AEB109A.7090506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> I'm finding it hard to follow 3 threads, for the 3 parts of the patch.
> 
> As I mentioned in one of these threads, I've plenty of experience with
> designing and implementing protocols for gaming.  And it seems to me that
> you're making changes to the entire TCP stack to make up for shortcomings
> in the implementor's design.  Yet, these changes require application
> implementors to set a sockopt that's only available in Linux.  Unlikely,
> as they probably don't even keep track of such things....
>

The target is not only games, but for instance SSH sessions, RDP or VNC, 
stock trading services, sensor networks and so forth. There are a lot of 
time-dependent applications that shows thin stream properties. Many of 
these use TCP, and will continue to use it. Some of these applications 
use UDP as default, but fall back to TCP if there is a problem with the 
UDP connection (for instance Skype). By providing better latency for thin 
streams, we can increase the service level for all these applications. 

Our experience is that at least some designers of interactive/time-dependent 
applications are skilled enough and concerned enough to investigate whether 
options exist that may improve the applications they are designing. Of 
course there are exceptions, but for open-sourced software, there will be 
people who can provide this input. If the argument is that there is no need 
for customised options because developers are stupid, we could strip away a 
lot of the existing network code.

> I've already suggested the end-to-end interest list, where you'll find many
> of us with a strong interest in this topic.

I've been reading end-to-end for several years, and I think I will take this 
discussion to that list eventually. We have discussed whether we should take 
this to end-to-end first, and netdev after, but decided to go here for the 
following reasons: 1) We have working patches that we wanted to contribute. 
2) The modifications are implemented as optional. 3) When active, the 
modifications handle a special case of TCP streams that we have shown to 
have minimal impact on general TCP behaviour.

Also, in my experience, the end-to-end list discussions tend to digress, 
making it difficult to keep the discussion to the special case that we 
address. Since we wanted technical and practical feedback that would help us
to refine the modifications in the patches in addition to the discussion on 
transport protocols, we chose to go to netdev first.

> The IETF has two related working groups:
>   tcpm -- tcp modifications
>   tsvwg -- general transport, including sctp modifications

There are plenty of examples of TCP mechanisms present in the Linux 
kernel that has not been standardised, for instance TCP CUBIC, the 
default congestion control for many Linux distributions at this time.

We have a set of patches, and a large body of experiments that shows them to
be effective for the thin-stream scenario without any significant disadvantages.
Please consider this before discarding the proposition based on a general 
principle of standardisation. We believe that the thin-stream modifications 
will provide extra value to Linux networking.

Best regards,
Andreas


