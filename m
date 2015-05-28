From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 0/9] drop unneeded goto
Date: Thu, 28 May 2015 23:02:15 +0200
Message-ID: <1432846944-7122-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, HPDD-discuss-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches drop gotos that jump to a label that is at the next
instruction, in the case that the label is not used elsewhere in the
function.  The complete semantic patch that performs this transformation is
as follows:

// <smpl>
@r@
position p;
identifier l;
@@

if (...) goto l@p;
l:

@script:ocaml s@
p << r.p;
nm;
@@

nm := (List.hd p).current_element

@ok exists@
identifier s.nm,l;
position p != r.p;
@@

nm(...) {
<+... goto l@p; ...+>
}

@depends on !ok@
identifier s.nm;
position r.p;
identifier l;
@@

nm(...) {
<...
- if(...) goto l@p; l:
...>
}
// </smpl>

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
