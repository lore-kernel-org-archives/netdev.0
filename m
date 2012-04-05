From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC PATCH 2/2] PID-based packet filtering support
Date: Thu, 5 Apr 2012 12:29:44 -0400
Message-ID: <CAAsGZS5ueTBGM7fj2RcRFX-8NAryH81stfFFZZip2hnRQzHRwg@mail.gmail.com>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
	<19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
	<CAAsGZS4Ndue7pVOohEHyWimffZECbjVLF40wiGkGXTswJimPCA@mail.gmail.com>
	<CALKxAXVK9EhJiNOuq0JYqWiw75q3TYCScp+bGf-qqF_irKYtbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: Nuno Martins <nuno.martins@caixamagica.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46937 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab2DEQ3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 12:29:45 -0400
Received: by pbcun15 with SMTP id un15so1730657pbc.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 09:29:44 -0700 (PDT)
In-Reply-To: <CALKxAXVK9EhJiNOuq0JYqWiw75q3TYCScp+bGf-qqF_irKYtbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 5, 2012 at 5:41 AM, Nuno Martins
<nuno.martins@caixamagica.pt> wrote:
> Our tests with 1024 node tree gives us something like 1.3 us on
> average. Your suggestion makes a lot of sense, and we will definitely
> look into.
> This doesn't seem hard to do as we are considering introducing a pid
> based hash table, with a tree in each entry, which can and possibly
> should be pre-allocated.

Also as a defensive mechanism(and if not present already) it may not
be a bad idea to add the following check whenever you are adding or
deleting a node:

if (pidmonitor->curr_num_monitored_pid_nodes >
pidmax_or_whichever_runtime_max_scheduler_uses) {
   WARN_ONCE(....);
    delete_all_nodes_from_the_tree(); // including the current one -
if you were in the middle of a new insert.
    // This way at least your monitoring tool might pick this up and
the user/sysadmin might dig into it.
}

Note: pidmonitor is some global struct and
curr_num_monitored_pid_nodes == number of pids you are currently
monitoring.

By adding this minimal code, if there are any stray nodes in the
tree(over a period of time) because of a bug in the clean up logic
then we might be able to detect it.


> Nuno Martins

Chetan
