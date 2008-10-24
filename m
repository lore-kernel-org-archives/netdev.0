From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 multicast forwarding
Date: Fri, 24 Oct 2008 13:12:29 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0810241307360.1106@netcore.fi>
References: <50a66e370810231511m10a10ca2oa870e9fbd55f4b0e@mail.gmail.com> <20081024111044.74c15155@varda>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1589707168-900059870-1224843149=:1106"
Cc: Todd Hayton <todd.hayton@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Alejandro_Riveira_Fern=E1ndez?=
	<ariveira@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:50382 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbYJXKMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 06:12:37 -0400
In-Reply-To: <20081024111044.74c15155@varda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1589707168-900059870-1224843149=:1106
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Fri, 24 Oct 2008, Alejandro Riveira Fernández wrote:
>> Let me apologize in advance for the length of this message - it is long!
>>
>> I'm trying to test out IPv6 multicast forwarding on a 2.6.26 kernel
>> and I'm getting some strange values for the upcall messages from the
>> kernel. My code is below, but to give an overview, my setup is as
>> follows:
>>
>>     sender ------ ff15::1 -----> [eth1] linux 2.6.26 [eth0] ------> ...

Maybe this isn't the bug you're looking for but you shouldn't be using 
ff1x multicast addresses in a test like this; ff1x means that the 
multicast group is of "interface-local scope" and it isn't useful for 
multicast forwarding.  So the kernel might be correct in not 
installing multicast forwarding state for a group address like this 
(but if it's a conscious decision, maybe the failure mode should be 
better).  See S 2.7 of RFC4291.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
--1589707168-900059870-1224843149=:1106--
