From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Thu, 29 Nov 2007 15:55:38 +0800
Message-ID: <474E707A.3080106@cn.fujitsu.com>
References: <20071119.142313.63549156.davem@davemloft.net>	<20071120002945.91fafb2b.billfink@mindspring.com>	<20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, billfink@mindspring.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk, bfields@fieldses.org, neilb@suse.de,
	okir@monad.swb.de, Wang Chen <wangchen@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:51017 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbXK2H6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 02:58:38 -0500
In-Reply-To: <20071120.173928.53148729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-21 9:39:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 20 Nov 2007 15:05:18 +0100
> 
>> On Tue, Nov 20, 2007 at 12:29:45AM -0500, Bill Fink wrote:
>>> While I agree with your analysis that it could be worked around,
>>> who knows how all the various SNMP monitoring applications out there
>>> would interpret such an unusual event.  I liked Stephen's suggestion
>>> of a deferred decrement that would insure the counter didn't ever
>>> run backwards.  But the best approach seems to be just not to count
>>> it in the first place until tha application has actually received
>>> the packet, since as Herbert pointed out, that's what the RFC
>>> actually specifies for the meaning of the udpInDatagrams counter.
>> Together with another counter that counts "edge datagrams received"
>> that would be an excellent idea.
>>
>> Here's a patch.
> 
> NFS and friends that use the ->data_ready() callback needs to
> be updated as well.  Please fix this and resubmit, thanks.
> 

I tested nfsv3 & nfsv4. It seems that nfs calls recvmsg() like
following:nfsd()->svc_recv()->svc_udp_recvfrom()->udp_recvmsg().
So, I think putting the udpInDatagrams increment in udp_recvmsg()
is enough.

FYI:
http://www.mail-archive.com/netdev@vger.kernel.org/msg13817.html


