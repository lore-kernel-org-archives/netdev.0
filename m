From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 22:19:43 +0300
Message-ID: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33582 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495AbXJaSR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 14:17:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we have the NET_NS config option, but the only change it 
makes is just return ERR_PTR(-EINVAL) inside the cloning call thus
introducing a bunch of a dead code and making the reference counting
unneeded. This is not very good.

So clean the net_namespace.c to fix this.

I have sent a set of patches to Andrew to make similar thing for
other namespaces, which introduces the NAMESPACES option to turn
all the namespaces off at once (to make embedded people suffer
less). So after that stuff is in, there will be some more patches 
to tie all this together.

What is to be done after this set is to make the register_pernet_xxx
stuff smaller. Currently this code weights approximately 500 bytes, 
so it worths reducing it, but I haven't found a good solution yet.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
