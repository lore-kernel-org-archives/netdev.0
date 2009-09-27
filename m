From: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
Subject: Re: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Sun, 27 Sep 2009 22:50:03 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0909272237190.4098@sister.anvils>
References: <1254076075.6583.6.camel@johannes.local>
 <Pine.LNX.4.64.0909272139280.4061@sister.anvils>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0909272139280.4061-T/S/X05ZC3jbmfIwyoSfiQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Sep 2009, Hugh Dickins wrote:
> 
> I've experimented by moving your NETDEV_PRE_INIT hunk later in the
> sequence, just before the netdev_initialize_kobject(dev) (so I also
> changed the "goto out" to "goto err_uninit"): both* machines then boot
> correctly, and this mail leaves me wirelessly.
> 
> I'll now experiment to see how early I can move that hunk.

Both machines boot (and do wireless) correctly with your NETDEV_PRE_INIT
hunk placed just after the ndo_init block, instead of just before where
you placed it.  That's i386 kernels on both.

But curiouser and curiouser... the laptop can do 64-bit, so I built
my 64-bit kernel, and went through the motions to reproduce the
early boot crash with the patch as you had it: but the x86_64 kernel
boots (and does wireless) correctly with the NETDEV_PRE_INIT hunk
just where you placed it, before the ndo_init block.

Perhaps there's a difference in the 32- and 64-bit startup sequence
with respect to notifiers; or perhaps your change tickles another bug.
I don't know, I'm turning off now.

Hugh
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
