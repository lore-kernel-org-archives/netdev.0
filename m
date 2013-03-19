From: Michal Kubecek <mkubecek@suse.cz>
Subject: Can we rely on ethernet header padding?
Date: Tue, 19 Mar 2013 16:05:45 +0100
Message-ID: <20130319150545.GA18218@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

a customer of ours ran into

  http://bugzilla.netfilter.org/show_bug.cgi?id=765

They checked that commit a504b86e prevents the crash but I'm not sure it
is sufficient.

The crash happens when br_nf_pre_routing_finish_bridge() calls
neigh_hh_bridge() which copies not only destination MAC address but also
the padding with it. IIUC this is for performance reasons (so that
aligned 8 bytes are copied rather than 6).

But I wonder whether we can rely on the fact that every skb on an
ethernet-like device has ethernet header padded at least to the 16 bytes
expected by neigh_hh_bridge() and neigh_hh_output() or whether the
bridge code should make sure. I tried to look for such test but couldn't
find any, even if commit a504b86e description mentions reallocating the
skb rather than a crash.

Thanks in advance,
                                                          Michal Kubecek

