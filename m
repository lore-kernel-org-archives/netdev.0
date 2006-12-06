From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Wed, 06 Dec 2006 14:54:16 +0300
Message-ID: <4576AF68.2070604@sw.ru>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost>	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>	<200612041900.42768.dim@openvz.org> <m1odqj8uyt.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:17301 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760511AbWLFLpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 06:45:03 -0500
To: devel@openvz.org
In-Reply-To: <m1odqj8uyt.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>If there is a better and less intrusive while still being obvious
>>>method I am all for it.  I do not like the OpenVZ thing of doing the
>>>lookup once and then stashing the value in current and the special
>>>casing the exceptions.
>>
>>Why?
> 
> 
> I like it when things are obvious and not implied.
> 
> The implementations seems to favor fewer lines of code touched over
> maintainability of the code.  Which if you are maintaining out of
> tree code is fine.  At leas that was my impression last time
> I looked at the code.
FYI, when we started doing networking virtualization many years ago
we tried both approaches.
Over time, context notion looked much more natural and easier for us.
Even Alexey Kuznetsov tells that he prefers exec_env as the logic
becomes very clear and little mess is introduced.

> I know there are a lot of silly things in the existing implementations
> because they were initially written without the expectation of being
> able to merge the code into the main kernel.  This resulted in some
> non-general interfaces, and a preference for patches that touch
> as few lines of code as possible.  
Sure, but OpenVZ code is being constantly cleaned from such code
and we are open for discussion. No one pretends that code is perferct
from the beginning.

> Anyway this has bit has been discussed before and we can discuss it
> seriously in the context of patch review.
Let me explain when explicit context like exec_env IMHO is cleaner:
- context is a natural notion of linux kernel. e.g. current.
  why not pass 'current' to all the functions as an argument
  starting from entry.S?
  in_atomic(), in_interrupt() etc. all these functions deal with current context.
  IMHO when one needs to pass an argument too many times like 'current'
  it is better to use a notion of the context.
- e.g. NFS should set networking context of the mount point or socket.
But, ok, it is not the real point to argue so much imho and waste our time instead of
doing things.

Thanks,
Kirill

