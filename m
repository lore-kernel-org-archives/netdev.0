From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 00/16] Labeled networking patches for 2.6.28
Date: Wed, 1 Oct 2008 12:24:26 -0400
Message-ID: <200810011224.26106.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <alpine.LRH.1.10.0810011128240.5277@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:1234 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbYJAQY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:24:29 -0400
In-Reply-To: <alpine.LRH.1.10.0810011128240.5277@tundra.namei.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 September 2008 9:34:24 pm James Morris wrote:
> I found some sparse warnings -- the last couple at least may need
> attention:
>
> $ make C=2 CF="-D__cold__=" SUBDIRS=net/netlabel

Ah ha!

At this point I have to admit a dirty little secret, I've never run 
sparse on any of my code before.  It isn't for a lack of trying it is 
just that I had no idea how to do so and googling for "sparse" and all 
the relevant Linux modifiers didn't result in much.  That command line 
helped quite a bit.

For others who may be interested you can find the sparse tool here:

 * http://www.kernel.org/pub/software/devel/sparse

... and it looks like the magic incantation is "make C={1,2}".  I have 
no idea what the "CF=..." bits do, James?

>   CHECK   net/netlabel/netlabel_user.c
>   CC      net/netlabel/netlabel_user.o
>   CHECK   net/netlabel/netlabel_kapi.c
>   CC      net/netlabel/netlabel_kapi.o
>   CHECK   net/netlabel/netlabel_domainhash.c
> net/netlabel/netlabel_domainhash.c:143:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_domainhash.c:143:3: originally declared here
> net/netlabel/netlabel_domainhash.c:143:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_domainhash.c:143:3: originally declared here
> net/netlabel/netlabel_domainhash.c:635:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_domainhash.c:635:3: originally declared here
> net/netlabel/netlabel_domainhash.c:635:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_domainhash.c:635:3: originally declared here CC
>      net/netlabel/netlabel_domainhash.o
>   CHECK   net/netlabel/netlabel_addrlist.c
>   CC      net/netlabel/netlabel_addrlist.o
>   CHECK   net/netlabel/netlabel_mgmt.c
>   CC      net/netlabel/netlabel_mgmt.o
>   CHECK   net/netlabel/netlabel_unlabeled.c
> net/netlabel/netlabel_unlabeled.c:265:2: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_unlabeled.c:265:2: originally declared here
> net/netlabel/netlabel_unlabeled.c:265:2: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_unlabeled.c:265:2: originally declared here
> net/netlabel/netlabel_unlabeled.c:1282:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_unlabeled.c:1282:3: originally declared here
> net/netlabel/netlabel_unlabeled.c:1282:3: warning: symbol
> '_________p1' shadows an earlier one
> net/netlabel/netlabel_unlabeled.c:1282:3: originally declared here CC
>      net/netlabel/netlabel_unlabeled.o
>   CHECK   net/netlabel/netlabel_cipso_v4.c
> net/netlabel/netlabel_cipso_v4.c:686:21: warning: incorrect type in
> argument 1 (different signedness)
> net/netlabel/netlabel_cipso_v4.c:686:21:    expected unsigned int
> [usertype] *skip_cnt
> net/netlabel/netlabel_cipso_v4.c:686:21:    got int *<noident>
> net/netlabel/netlabel_cipso_v4.c:622:2: warning: context imbalance in
> 'netlbl_cipsov4_list' - different lock contexts for basic block CC   
>   net/netlabel/netlabel_cipso_v4.o
>   LD      net/netlabel/built-in.o
>   Building modules, stage 2.
>   MODPOST 0 modules

Thanks, I went ahead and fixed all of the problems.  I'll send an 
updated patchset later after I can do a quick sanity test.

-- 
paul moore
linux @ hp
