From: Matt Mackall <mpm@selenic.com>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Wed, 22 Dec 2004 09:18:36 -0800
Message-ID: <20041222171836.GL5974@waste.org>
References: <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com> <20041221123727.GA13606@electric-eye.fr.zoreil.com> <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com> <20041221204853.GA20869@electric-eye.fr.zoreil.com> <20041221212737.GK5974@waste.org> <20041221225831.GA20910@electric-eye.fr.zoreil.com> <41C93FAB.9090708@trash.net> <41C9525F.4070805@trash.net> <20041222123940.GA4241@electric-eye.fr.zoreil.com> <41C98B75.9020802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Mark Broadbent <markb@wetlettuce.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261999AbULVRTQ@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41C98B75.9020802@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2004 at 03:57:57PM +0100, Patrick McHardy wrote:
> >Of course the patch is completely ugly and violates any layering
> >principle one could think of. It was not submitted for inclusion :o)
> 
> Sure, but I think we should have a short-term workaround until
> a better solution has been invented. Maybe dropping the packets
> would be best for now, it only affects printks issued in paths
> starting at qdisc_restart (-> hard_start_xmit -> ...). Queueing
> the packets might also cause reordering since not all packets
> are queued.

When I mentioned queueing, I was thinking of a netpoll-private queue
that would be hooked to a softirq or some such so that it would be
pushed out as soon as possible. Dropping may be the better approach as
queueing throws away netpoll's immediacy and ordering properties. And
getting netpoll _more_ tangled in the net stack mechanics is
definitely a step in the wrong direction.

More generally, I'm tempted to add some warn_on style functionality so
that printks in such troublesome paths can be lifted out.

-- 
Mathematics is the supreme nostalgia of our time.
