From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH/RFC v2 0/13] enable SKB paged fragment lifetime visibility
Date: Fri, 22 Jul 2011 14:08:15 +0100
Message-ID: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This is v2 of my series to enable visibility into SKB paged fragment's
lifecycles, v1 is at [0] and contains some more background and rational=
e
but basically the series allows entities which inject pages into the
networking stack to receive a notification when the stack has really
finished with those pages (i.e. including retransmissions, clones,
pull-ups etc) and not just when the original skb is finished with, whic=
h
is beneficial to many subsystems which wish to inject pages into the
network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have updated based on the feedback from last time. In particular:
      * Added destructor directly to sendpage() protocol hooks instead
        of inventing sendpage_destructor() (David Miller)
      * Dropped skb_frag_pci_map in favour of skb_frag_dma_map on Micha=
=C5=82
        Miros=C5=82aw's advice
      * Pushed the NFS fix down into the RPC layer. (Trond)

I also split out the patches to make protocols use the new interface
into per-protocol patches. I held back on splitting up the patch to
drivers/* (since that will cause an explosion in the series length) --
I'll do this split for v3.

=46YI I'm travelling for the next two weeks, although I expect to have
good access to mail next week I'm less sure about the following week.

Cheers,
Ian.

[0] http://marc.info/?l=3Dlinux-netdev&m=3D131072801125521&w=3D2
[1] http://marc.info/?l=3Dlinux-netdev&m=3D130925719513084&w=3D2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
