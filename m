From: Tobias DiPasquale <codeslinger@gmail.com>
Subject: Re: deleting a conntrack record
Date: Thu, 17 Jun 2004 12:17:39 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <876ef97a04061709173c8f1a09@mail.gmail.com>
References: <876ef97a0406170807663b89e0@mail.gmail.com> <40D1C088.4090307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev <netdev@oss.sgi.com>, linux-net <linux-net@vger.kernel.org>,
	netfilter <netfilter-devel@lists.netfilter.org>
In-Reply-To: <40D1C088.4090307@trash.net>
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 18:02:16 +0200, Patrick McHardy <kaber@trash.net> wrote:
> Why don't you just adjust the timeout values in
> /proc/sys/net/ipv4/netfilter ?

Can't, because I only want to shorten the lifespans of some particular
TCP connections and also when I delete a record I need to do some
other stuff that's associated with the destruction of that connection.
 
> The function passed to ip_ct_selective_cleanup is supposed to decide
> if a conntrack should be destroyed by returning 0/1, not to do it
> itself. ip_ct_selective_cleanup tries to destroy the already destroyed
> conntrack.

This results in a memory leak in the conntrack slab cache. If you
don't call ip_conntrack_put(), the conntrack entry leaves the
ip_ct_selective_cleanup() function with a value >0 and thus is a
permanent part of the scenery in RAM. As well, its been removed from
the conntrack hash table, so it no longer appears in
/proc/net/ip_conntrack, but you can see the effects by viewing
/proc/slabinfo.

I have printed the integral value of the ct_general.use variable out
in order to confirm this on many occassions. If this is not the case,
then something extremely weird is going on with my kernel.

(btw, the kernel is a kernel.org 2.4.26 with the clear_fpu and the
2.4.26 LKCD (from the ML) patch applied)

-- 
[ Tobias DiPasquale ]
0x636f6465736c696e67657240676d61696c2e636f6d
