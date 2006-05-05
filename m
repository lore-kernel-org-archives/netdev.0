From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Very long list of struct dst_entry in dst_garbage_list
Date: Fri, 05 May 2006 18:13:30 +0200
Message-ID: <445B79AA.7030209@cosmosbay.com>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>	<4459574D.6000303@candelatech.com>	<cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com> <20060504.162546.88959729.davem@davemloft.net> <445B11A3.1020407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.wanadoo.fr ([193.252.22.28]:53025 "EHLO smtp3.wanadoo.fr")
	by vger.kernel.org with ESMTP id S1751621AbWEEQNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 12:13:35 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf0304.wanadoo.fr (SMTP Server) with ESMTP id 92ECE1C00CB0
	for <netdev@vger.kernel.org>; Fri,  5 May 2006 18:13:34 +0200 (CEST)
Received: from dniepr.adsl.jetmultimedia.fr (LNeuilly-152-23-22-3.w193-252.abo.wanadoo.fr [193.252.36.3])
	by mwinf0304.wanadoo.fr (SMTP Server) with SMTP id 5FB4B1C00CAF
	for <netdev@vger.kernel.org>; Fri,  5 May 2006 18:13:34 +0200 (CEST)
Received: from [127.0.0.1] (lysm252200p.groupejet.priv [192.168.5.42] (may be forged))
	by dniepr.adsl.jetmultimedia.fr (8.11.7+Sun/8.11.7) with SMTP id k45GDWO10488
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 18:13:33 +0200 (MEST)
To: netdev@vger.kernel.org
In-Reply-To: <445B11A3.1020407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed that after a 'ip route flush cache' (manual or timer 
triggered) on a busy server, XXXXX entries are added to dst_garbage_list.
(XXXXX depends on the number of established sockets)

Every 1/10th second (DST_GC_MIN) , net/core/dst.c::dst_run_gc() is 
fired, and try to free some entries from the list, but many entries have 
a non null refcnt and stay in the list for the next run.

Linux version is 2.6.17-rc3.

Do you think a rework of  dst_run_gc() function is necessary, (using a 
batch mode to limit the number of entries examined at each run), or is 
it a "should not happen, something is broken" situation ?

Eric



