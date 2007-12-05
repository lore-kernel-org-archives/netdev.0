From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Date: Wed, 5 Dec 2007 13:45:18 +0000
Message-ID: <20071205134518.GC893@gerrit.erg.abdn.ac.uk>
References: <1196631416-17778-1-git-send-email-acme@redhat.com> <20071203083512.GA5484@gerrit.erg.abdn.ac.uk> <20071203124412.GC15034@ghostprotocols.net> <20071203134947.GD18547@gerrit.erg.abdn.ac.uk> <20071203145443.GE15034@ghostprotocols.net> <20071205102736.GF5177@gerrit.erg.abdn.ac.uk> <20071205115226.GM29972@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36845 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751947AbXLENqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 08:46:15 -0500
Content-Disposition: inline
In-Reply-To: <20071205115226.GM29972@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > Patch #3: 
| > ---------
| >   Renames s/tfrc_tx_hist/tfrc_tx_hist_slab/g; no problems.
| 
| This was for consistency with the other slabs in DCCP:
| 
| [acme@doppio net-2.6.25]$ find net/dccp/ -name "*.c" | xargs grep 'struct kmem_cache'
Thanks, I will put the same naming scheme also in the test tree (tomorrow).

 
| > Patch #4:
| > ---------
| > Just a suggestion, it is possible to simplify this further,
| >   by doing all the initialisation / cleanup in tfrc.c:
| >     int __init {rx,tx}_packet_history_init()
| >     {
| > 	    tfrc_{rx,tx}_hist_slab = kmem_cache_create("tfrc_{rx,tx}_hist", ...);
| > 	    return tfrc_{rx,tx}_hist_slab == NULL ? - ENOBUFS : 0;
| >     }
| >   and then call these successively in tfrc_module_init().
| 
| Idea here was to have each C source file to have a init module. Perhaps
| we should try to break packet_history.c into tx_packet_history and
| rx_packet_history.c. We can do that later to try to meet the goal of
| being able to see what is being replaced.
|
I think this is a great idea, since then rx_packet_history.c could also
take up all the internals of the RX packet history list, as it is
currently done for the TX history, and it could also possibly
incorporate. packet_history_internal.h.


|  
| > Patch #7:
| > ---------
|  
| >  * tfrc_rx_hist_entry_data_packet() is not needed:
| >    - a similar function, called dccp_data_packet(), was introduced in patch 2/7
| 
| I thought about that, but dccp_data_packet is for skbs,
| tfrc_rx_hist_entry_data_packet is for tfrc_rx_hist_entries, I guess we
| should just make dccp_data_packet receive the packet type and not an
| object that has a packet type field.
| 
The question which of the two interfaces is generally better to use is
best left to you. Two functions doing almost the same thing can probably
be replaced by just one.
