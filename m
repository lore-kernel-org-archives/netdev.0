From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: binding UDP port 0 with SO_REUSEADDR
Date: Tue, 21 Aug 2012 11:09:55 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208211053130.1100@frira.zrqbmnf.qr>
References: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>  <1343847776.21269.797.camel@edumazet-glaptop>  <CAEZM=bPqOgRUvUKfdYkrVXoWin+SMft0GK67hqsGhBD6nocryA@mail.gmail.com>  <CAEZM=bM=AGp=FOxLiDiBFgVJWGmNdPpG_FV3Ne2i5jeALiB4YA@mail.gmail.com>
 <1343926645.9299.303.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:56613 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196Ab2HUJJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 05:09:57 -0400
In-Reply-To: <1343926645.9299.303.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2012-08-02 18:57, Eric Dumazet wrote:
>>SO_REUSEADDR
>>       Indicates  that  the rules used in validating addresses supplied
>>       in a bind(2) call should allow reuse of  local  addresses.   For
>>       AF_INET  sockets  this means that a socket may bind, except when
>>       there is an active listening socket bound to the address.   When
>>       the listening socket is bound to INADDR_ANY with a specific port
>>       then it is not possible to bind  to  this  port  for  any  local
>>       address.  Argument is an integer boolean flag.
>> 
>> I think the surprise-factor of the bind-0-behaviour even increased for
>> me. Is there a specific reason for handing out used ports when binding
>> port 0 with REUSEADDR?
>
>There is no concept of listening sockets for UDP.
>This documentation applies for TCP, and makes no sense for UDP.
>There is no value using 'port 0' and REUSEADDR on UDP, really.

Setting REUSEADDR on one UDP socket currently has the added effect
that bind(2) on another UDP socket for the same tuple will never
complain with -EADDRINUSE.

This behavior - willingly or not - is used in practice by socat(1)'s
udp-listen mode.
