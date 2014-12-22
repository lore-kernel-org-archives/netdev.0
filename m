From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH 01/17] fib_trie: Update usage stats to be percpu
 instead of global variables
Date: Mon, 22 Dec 2014 11:21:44 -0800
Message-ID: <CAHA+R7P1i1B2F5e7kR-rAsQPRL0F0=r7J06qu68kxQ5N9q5H9Q@mail.gmail.com>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<20141222174058.1119.55120.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:47831 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbaLVTVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 14:21:45 -0500
Received: by mail-qg0-f46.google.com with SMTP id q107so3698414qgd.33
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 11:21:45 -0800 (PST)
In-Reply-To: <20141222174058.1119.55120.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 9:40 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> @@ -1388,7 +1388,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
>                 }
>
>  #ifdef CONFIG_IP_FIB_TRIE_STATS
> -               t->stats.semantic_match_miss++;
> +               this_cpu_ptr(t->stats->semantic_match_miss);


You mean this_cpu_inc() ?
