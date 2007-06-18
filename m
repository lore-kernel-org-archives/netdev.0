From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [Bugme-new] [Bug 8638] New: unregister_netdevice: waiting for
 ppp0 to become free. pppoe + multihome + htb qos?
Date: Mon, 18 Jun 2007 10:56:06 -0400
Message-ID: <46769D06.3050603@redhat.com>
References: <bug-8638-10286@http.bugzilla.kernel.org/> <20070616083454.1612ca7f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	Paul Mackerras <paulus@samba.org>, kernelbugs@tecnopolis.ca
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763349AbXFRO5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 10:57:13 -0400
In-Reply-To: <20070616083454.1612ca7f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Is there any way to print the addresses the notifier is calling
to try and release net device references? I see:

net/core/dev/c::netdev_wait_allrefs():

        while (atomic_read(&dev->refcnt) != 0) {
                if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
                        rtnl_lock();

                        /* Rebroadcast unregister notification */
                        raw_notifier_call_chain(&netdev_chain,
                                            NETDEV_UNREGISTER, dev);

but don't see any way to print the functions that get called.
