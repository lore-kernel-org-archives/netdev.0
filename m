From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 07:29:55 +0200
Message-ID: <446811D3.5080905@trash.net>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei> <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net> <Pine.LNX.4.64.0605150004590.645@d.namei>
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
Received: from stinky.trash.net ([213.144.137.162]:63360 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932175AbWEOF35
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 01:29:57 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605150004590.645@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Sun, 14 May 2006, Patrick McHardy wrote:
> 
> 
>>James Morris wrote:
>>
>>>@@ -135,6 +175,9 @@ static int __init xt_secmark_init(void)
>>> {
>>> 	int err;
>>> 
>>>+	if (tracking_enabled())
>>>+		need_conntrack();
>>>+
>>
>>This will load the conntrack modules even if the track flag is not set.
> 
> 
> I guess need_conntrack() could be moved to checkentry() and only called 
> if the track flag is set.


That won't help, the function itself does nothing, its just a symbol
dependency.

>>Wouldn't it be better to put everything related to connection marking
>>in the CONNSECMARK target?
> 
> 
> It's more efficient this way, and simpler to manage.  
> 
> Currently, after security marking, the chain should normally terminate 
> with a -j ACCEPT.  Requiring the use of CONNSECMARK to label connections 
> means inserting another rule before terminating the chain.
> 
> Also, security marking for connections only occurs in the context of 
> copying the security mark from packets, so there's no reason to build a 
> general feature to do this into CONNSECMARK.
> 
> Another possibility would be to get rid of CONNSECMARK completely and have 
> SECMARK copy security marks from connections to packets via the use of a 
> different flag (perhaps change --track into --save-state and then have 
> --restore-state, or similar).


The reason why I'm asking is because my understanding is that SECMARK
would also be useful without conntrack, but automatically pulling in
the module leaves no option not to use conntrack except not to compile
this part in.
