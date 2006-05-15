From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 08:26:23 +0200
Message-ID: <44681F0F.9030601@trash.net>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei> <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net> <Pine.LNX.4.64.0605150004590.645@d.namei> <446811D3.5080905@trash.net> <Pine.LNX.4.64.0605150153590.1275@d.namei> <446819FE.8050300@trash.net> <Pine.LNX.4.64.0605150221000.1275@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27525 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932320AbWEOG0Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 02:26:25 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605150221000.1275@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 15 May 2006, Patrick McHardy wrote:
> 
> 
>>>Not sure what you mean: it will cause ip_conntrack to be loaded, which 
>>>is needed when you specify the track flag.
>>
>>
>>Yes, but the reason why it is loaded is because the module loader needs
>>to resolve the symbol, not because of anything done at module runtime.
> 
> 
> Am I missing something?  This is what I want to happen.  If you specify 
> SECMARK --track,  ip_conntrack is to be loaded.


But if you don't specify --track, the module loader will still have to
resolve the symbol, so it gets loaded anyway, before your code will
even run. Just look at need_conntrack():

/* Some modules need us, but don't depend directly on any symbol.
   They should call this. */
void need_conntrack(void)
{
}
