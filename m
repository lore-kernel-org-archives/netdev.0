From: Ed W <lists@wildgooses.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 00:01:37 +0100
Message-ID: <4C3E41D1.1090609@wildgooses.com>
References: <4C3D94E3.9080103@wildgooses.com> <4C3DD5EB.9070908@tmr.com> <20100714.111553.104052157.davem@davemloft.net> <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com> <20100714203919.GD6682@nuttenaction> <4C3E34AB.2060405@wildgooses.com> <20100714223633.GJ6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.nippynetworks.com ([212.227.250.41]:59492 "EHLO
	mail1.nippynetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185Ab0GNXBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 19:01:39 -0400
In-Reply-To: <20100714223633.GJ6682@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Do you cite "An Argument for Increasing TCP's Initial Congestion Window"?
> People at google stated that a CWND of 10 seems to be fair in their
> measurements. 10 because the test setup was equipped with a reasonable large
> link capacity? Do they analyse their modification in environments with a small
> BDP (e.g. multihop MANET setup, ...)? I am curious, but We will see what
> happens if TCPM adopts this.
>    

Well, I personally would shoot for starting from the position of 
assuming better than zero knowledge about our link and incorporating 
that into the initial cwnd estimate...

We know something about the RTT from the syn/ack times, speed of the 
local link and quickly we will learn about median window sizes to other 
destinations, plus additionally the kernel has some knowledge of other 
connections currently in progress.  With all that information perhaps we 
can make a more informed option than just a hard coded magic number? (Oh 
and lets make the option pluggable so that we can soon have 10 different 
kernel options...)

Seems like there is evidence that networks are starting to cluster into groups that would benefit from a range of cwnd options (higher/lower) - perhaps there is some way to choose a reasonable heuristic to cluster these and choose a better starting option?

Cheers

Ed W


