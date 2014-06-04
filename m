From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Tue, 03 Jun 2014 17:24:51 -0700 (PDT)
Message-ID: <20140603.172451.2132501802596004067.davem@davemloft.net>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	<1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934101AbaFDAYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 20:24:53 -0400
In-Reply-To: <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  3 Jun 2014 17:11:55 -0700

> "list_kill" is allocated on stack and it's a list head,
> it is pointless to call list_del(&kill_list) especially
> after unregister_netdevice_many().
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Do not edit what you do not understand:

commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e                                                                         
Author: Eric Dumazet <eric.dumazet@gmail.com>                                                                           
Date:   Thu Feb 17 22:59:19 2011 +0000                                                                                  
                                                                                                                        
    net: deinit automatic LIST_HEAD                                                                                     
                                                                                                                        
    commit 9b5e383c11b08784 (net: Introduce                                                                             
    unregister_netdevice_many()) left an active LIST_HEAD() in                                                          
    rollback_registered(), with possible memory corruption.                                                             
                                                                                                                        
    Even if device is freed without touching its unreg_list (and therefore                                              
    touching the previous memory location holding LISTE_HEAD(single), better                                            
    close the bug for good, since its really subtle.                                                                    
                                                                                                                        
    (Same fix for default_device_exit_batch() for completeness)                                                         
                                                                                                                        
    Reported-by: Michal Hocko <mhocko@suse.cz>                                                                          
    Tested-by: Michal Hocko <mhocko@suse.cz>                                                                            
    Reported-by: Eric W. Biderman <ebiderman@xmission.com>                                                              
    Tested-by: Eric W. Biderman <ebiderman@xmission.com>                                                                
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>                                                       
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>                                                                
    CC: Ingo Molnar <mingo@elte.hu>                                                                                     
    CC: Octavian Purdila <opurdila@ixiacom.com>                                                                         
    CC: stable <stable@kernel.org> [.33+]                                                                               
    Signed-off-by: David S. Miller <davem@davemloft.net>                                                                
