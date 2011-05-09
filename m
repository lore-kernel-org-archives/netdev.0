From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Mon, 09 May 2011 06:37:44 +0100
Message-ID: <BA03B09F0474B30660A091FD@nimrod.local>
References: <1304793749.3207.26.camel@edumazet-laptop>	
 <1304838742.3207.45.camel@edumazet-laptop>	
 <F57561A93EFF5E88729A8D53@nimrod.local>	
 <7B76F9D75FD26D716624004B@nimrod.local>	
 <20110508125028.GK2641@linux.vnet.ibm.com>	
 <B2891EFD056565BBD4DBCE16@nimrod.local>	
 <20110508134425.GL2641@linux.vnet.ibm.com>	
 <C449131127D58077CB25C9D8@Ximines.local>	
 <20110508144749.GR2641@linux.vnet.ibm.com>	
 <AB9DE9E04289CF29CA79CC67@Ximines.local>	
 <20110508154854.GT2641@linux.vnet.ibm.com>
 <1304888447.3207.66.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>, paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:43613 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab1EIFhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 01:37:48 -0400
In-Reply-To: <1304888447.3207.66.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 8 May 2011 23:00:47 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> We can probably speed things, but we should consider the following user
> actions :

How about

> ip link add link eth0 vlan103 type vlan id 103
> ip link del vlan103

Removes and unlinks structures, including making name available, sending
out netlink messages, but doesn't free things

> ip link add link eth1 vlan103 type vlan id 103

creates new interface

[some time later] original zombie i/f freed

> The "link del" command should return to user only if the minimum things
> had been done, to make sure the following "link add" wont fail
> mysteriously.

Are you worried about failure through name collision (already
dealt with), vlan tag collision (ditto) or what?

-- 
Alex Bligh
