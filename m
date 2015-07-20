From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Why return E2BIG from bpf map update?
Date: Mon, 20 Jul 2015 15:15:50 -0700
Message-ID: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: ast@plumgrid.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34487 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757226AbbGTWQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 18:16:11 -0400
Received: by qgeu79 with SMTP id u79so23935578qge.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 15:16:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ship has probably sailed on this one, but it seems like ENOSPC
makes more sense than E2BIG.  Any chance of changing it so that poor
ebpf library maintainers in the future don't have to wonder how their
argument list got too big?

net-next/master:kernel/bpf/hashtab.c=static int
htab_map_update_elem(struct bpf_map *map, void *key, void *value,
--
net-next/master:kernel/bpf/hashtab.c-
net-next/master:kernel/bpf/hashtab.c-   if (!l_old &&
unlikely(htab->count >= map->max_entries)) {
net-next/master:kernel/bpf/hashtab.c-           /* if elem with this
'key' doesn't exist and we've reached
net-next/master:kernel/bpf/hashtab.c-            * max_entries limit,
fail insertion of new elem
net-next/master:kernel/bpf/hashtab.c-            */
net-next/master:kernel/bpf/hashtab.c:           ret = -E2BIG;
net-next/master:kernel/bpf/hashtab.c-           goto err;
net-next/master:kernel/bpf/hashtab.c-   }
net-next/master:kernel/bpf/hashtab.c-
net-next/master:kernel/bpf/hashtab.c-   if (l_old && map_flags == BPF_NOEXIST) {
net-next/master:kernel/bpf/hashtab.c-           /* elem already exists */

-- 
Alex Gartrell <agartrell@fb.com>
