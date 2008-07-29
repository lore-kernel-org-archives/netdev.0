From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 09:11:35 +0300
Message-ID: <200807290911.35809.denys@visp.net.lb>
References: <200807290843.29447.denys@visp.net.lb> <488EB07D.50406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:55130 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbYG2GL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:11:58 -0400
In-Reply-To: <488EB07D.50406@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, the issue not with ifb0 only. It is just not parsing rules correctly i think:

rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(protocol eq 1234\) classid 1:100
rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(data_len eq 1234\) classid 1:100

filter parent 1: protocol all pref 49151 basic
filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
  meta(-1 eq 1234)

filter parent 1: protocol all pref 49152 basic
filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
  meta(-1 eq 1234)



On Tuesday 29 July 2008, Patrick McHardy wrote:
> Denys Fedoryshchenko wrote:
> > Kernel 2.6.26, iproute2 latest release. All required modules is loaded.
> > What did i miss or doing wrong?
> >
> > tc filter add dev ifb0 protocol all basic match "meta(rt_iif eq tap0)" classid 1:100 
> >
> > tc -s -d filter show dev ifb0
> > filter parent 1: protocol all pref 49152 basic
> > filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
> >   meta(-1 eq -1)
> >
> > Whatever i try - it doesn't work
> > ./tc filter add dev ifb0 protocol all basic match meta \(rt_iif eq tap0\) classid 1:100
> >   
> 
> You probably need to add support for skb->iif in case the
> packet didn't went through IPv4.
> 


