From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 0/10] Make fragments live in net namespaces
Date: Tue, 22 Jan 2008 16:52:36 +0300
Message-ID: <4795F524.8060204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41993 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbYAVNwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 08:52:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The overall design I propose is to keep the hash table
global and tag inet_frag_queue with the net. Since the 
fragments hash is going to be re-sizable, this is OK to 
keep fragments from different namespace in one hash.

To speedup the evicting process LRU list is made per
namespace.

As far as the CTL-tuned variables are concerned, the
timeout and thresholds are made per namespace, since
they have the per namespace sense, but the secret rebuild
interval is read-only in sub-namespaces.

Since fragment management code is consolidated for ipv4
and ipv6 I make them all in one go. The conntrack_reasm
netns-ization is not done - we have to make at least the 
core netfilter per namespace first, but this reasm code 
is patched to keep working in the initial namespace.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
