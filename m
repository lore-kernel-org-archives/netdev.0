From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 16:50:46 -0700
Message-ID: <470EB6D6.9020704@hp.com>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com> <20071011.163737.36654032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51101 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667AbXJKX4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 19:56:15 -0400
In-Reply-To: <20071011.163737.36654032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Thu, 11 Oct 2007 16:27:14 -0700
> 
> 
>>I'm having an issue with TSO right vs. hardware that can't take the
>>maximum segment size sent from the stack.  I've been told that the
>>maximum packet size that can be sent to the hardware today is 64k, but
>>my hardware can only take 32k in certain modes per queue due to hardware
>>limitations. 

Bletch.

>> I have two questions regarding this: 1) where is this
>>value set in the TCP code, and 2) Is this something that can be
>>configured on the fly?  If the answer to 2 is no, I will try and put
>>something together to allow this to happen.
> 
> 
> The TCP code just builds the maximum possible for the underlying
> protocol, be it ipv4 or ipv6.  It takes the underlying protocol
> maximum packet length, subtracts the amount of header space it
> knows will be used, and uses that.
> 
> You'll need to use GSO sw segmentation to split the TSO packets
> which are too big for your HW to handle.

For just messing about, might it be possible to tweak the socket buffer sizes 
and tcp_tso_win_divisor to kludge things for a short while?  Couldn't ship that 
way certainly, but assuming Peter's going to get his broken hardware fixed it 
might let him limp along until then.

rick jones
