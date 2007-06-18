From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8638] New: unregister_netdevice: waiting for
 ppp0 to become free. pppoe + multihome + htb qos?
Date: Mon, 18 Jun 2007 08:18:18 -0700
Message-ID: <20070618081818.01dbf2b5@localhost.localdomain>
References: <bug-8638-10286@http.bugzilla.kernel.org/>
	<20070616083454.1612ca7f.akpm@linux-foundation.org>
	<46769D06.3050603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	Paul Mackerras <paulus@samba.org>, kernelbugs@tecnopolis.ca
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37311 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764054AbXFRPTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 11:19:19 -0400
In-Reply-To: <46769D06.3050603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 10:56:06 -0400
Chuck Ebbert <cebbert@redhat.com> wrote:

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

You could walk the chain and print the functions out, but it wouldn't
really help identify the problem. The problem is when a protocol forgets
to call dev_put() after calling dev_hold().  The notifier there is
just a last effort at beating a dead horse. It really should be removed
since it never helps.  The notifier in unregister does work, and calling
the notification repeatedly doesn't change anything.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
