From: walter harms <wharms@bfs.de>
Subject: Re: [patch v2] bridge: make buffer larger in br_setlink()
Date: Fri, 07 Dec 2012 20:15:42 +0100
Message-ID: <50C2405E.1070904@bfs.de>
References: <20121207111045.GA9676@elgon.mountain> <50C2143C.2010200@bfs.de> <20121207185359.GP22569@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:27585 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab2LGTPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 14:15:44 -0500
In-Reply-To: <20121207185359.GP22569@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 07.12.2012 19:53, schrieb Dan Carpenter:
> On Fri, Dec 07, 2012 at 05:07:24PM +0100, walter harms wrote:
>>
>>
>> Am 07.12.2012 12:10, schrieb Dan Carpenter:
>>> We pass IFLA_BRPORT_MAX to nla_parse_nested() so we need
>>> IFLA_BRPORT_MAX + 1 elements.  Also Smatch complains that we read past
>>> the end of the array when in br_set_port_flag() when it's called with
>>> IFLA_BRPORT_FAST_LEAVE.
>>>
>>
>>
>>
>> I have no clue why nla_parse_nested() need IFLA_BRPORT_MAX elements.
>> but the majory of loop look like
>> for(i=0;i<max;++)
>> most programmers will think this way.
>> So it seems the place to fix is nla_parse_nested().
>> doing not so is asking for trouble (in the long run).
>> At least this function needs a big warning label that (max-1)
>> is actually needed.
>>
> 
> Yeah, nla_parse_nested() is actually documented already.
> 


documenting unexspected behavier is not as much helpfull as changing it.

just my 2 cents,
 wh
