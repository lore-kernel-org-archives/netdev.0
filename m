From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: don't use IPCB() to locate the CIPSO IP option
Date: Fri, 06 Feb 2015 15:03:05 -0500
Message-ID: <79075962.e3G0NVBHuh@sifl>
References: <20150206195728.28733.12118.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	casey@schaufler-ca.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20150206195728.28733.12118.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, February 06, 2015 02:57:28 PM Paul Moore wrote:
> Using the IPCB() macro to get the IPv4 options is convenient, but
> unfortunately NetLabel often needs to examine the CIPSO option outside
> of the scope of the IP layer in the stack.  While historically IPCB()
> worked above the IP layer, due to the inclusion of the inet_skb_param
> struct at the head of the {tcp,udp}_skb_cb structs, recent commit
> 971f10ec ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> reordered the tcp_skb_cb struct and invalidated this IPCB() trick.
> 
> This patch fixes the problem by creating a new function,
> cipso_v4_optptr(), which locates the CIPSO option inside the IP header
> without calling IPCB().  Unfortunately, this isn't as fast as a simple
> lookup so some additional tweaks were made to limit the use of this
> new function.
> 
> Cc: <stable@vger.kernel.org> # 3.18
> Reported-by: Casey Schaufler <casey@schaufler-ca.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

DaveM, I'd prefer this go upstream via the SELinux/security tree so we don't 
have to worry about syncing up with the netdev tree to get this fix.  Any 
objections on your part (this patch only touches NetLabel/CIPSO)?

-- 
paul moore
security @ redhat

