From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8638] New: unregister_netdevice: waiting for
 ppp0 to become free. pppoe + multihome + htb qos?
Date: Mon, 18 Jun 2007 08:23:31 -0700
Message-ID: <20070618082331.d1b7fd93.akpm@linux-foundation.org>
References: <bug-8638-10286@http.bugzilla.kernel.org/>
	<20070616083454.1612ca7f.akpm@linux-foundation.org>
	<46769D06.3050603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	Paul Mackerras <paulus@samba.org>, kernelbugs@tecnopolis.ca
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60621 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762948AbXFRPYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 11:24:34 -0400
In-Reply-To: <46769D06.3050603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 10:56:06 -0400 Chuck Ebbert <cebbert@redhat.com> wrote:

> 
> Is there any way to print the addresses the notifier is calling
> to try and release net device references? I see:
> 
> net/core/dev/c::netdev_wait_allrefs():
> 
>         while (atomic_read(&dev->refcnt) != 0) {
>                 if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
>                         rtnl_lock();
> 
>                         /* Rebroadcast unregister notification */
>                         raw_notifier_call_chain(&netdev_chain,
>                                             NETDEV_UNREGISTER, dev);
> 
> but don't see any way to print the functions that get called.

Nope.  I guess we could add some print_notifier_call_chain() thing, but
then we'd need one flavour per locking scheme and it would get ridiculous.

I guess just an unlocked version would be OK - it's just a debug thing.
