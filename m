From: "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>
Subject: RE: IPV6 stateless address autoconfiguration
Date: Mon, 12 May 2008 15:36:57 -0400
Message-ID: <BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net>
References: <20080513.004620.117676648.yoshfuji@linux-ipv6.org><OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com> <20080513.021736.125105716.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wbmler3.mail.xerox.com ([13.13.138.218]:48500 "EHLO
	wbmler3.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbYELUTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 16:19:18 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080513.021736.125105716.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> In article
> <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com>
> (at Mon, 12 May 2008 10:00:21 -0700), David Stevens
> <dlstevens@us.ibm.com> says:   
> 
>>> +         } else if (~rt_expires) {
>>> +            /* not infinity */
>>> +            rt->rt6i_expires = jiffies + rt_expires;
>>> +            rt->rt6i_flags |= RTF_EXPIRES;
>> 
>>         rt_expires is "unsigned long" -- won't the high-order bits
>>         be set on 64-bit machines? Also, don't you need to check
>> before the divide by USER_HZ? 
> 
> Oops, I'm afraid I sent a wrong file, sorry.
> 
> This is the correct version.
> (...and I plan to come up with more fixes for real application on top
> of the net tree.) 
> 
> Sighed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 

I did some testing with the second patch.  My router is still configured
to send RA's with prefix information valid_lft = preferred_lft = 0xffffffff.
It works except for one thing: the initial prefix route (after the first RA)
shows an expire time when using
   ip -6 route list
If I keep checking I can see the expires time counting down.  After some
minutes the expires field disappeares from the ip -6 route list output.
I tracked it down and it looks like when a subsequent RA is received
with the same prefix is when the expires time stops showing up.

Joe
