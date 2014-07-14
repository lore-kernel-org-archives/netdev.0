From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] openvswitch: Allow each vport to have an array
 of 'port_id's.
Date: Mon, 14 Jul 2014 16:17:26 -0700 (PDT)
Message-ID: <20140714.161726.579481406574025687.davem@davemloft.net>
References: <1405296774-3648-1-git-send-email-pshelar@nicira.com>
	<20140714.151337.573086784322485064.davem@davemloft.net>
	<CALnjE+pSnhG4W55j-QBhsQLdmHQ1BU-rLbjj_Nf-Ju04Y1972g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexw@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbaGNXR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 19:17:27 -0400
In-Reply-To: <CALnjE+pSnhG4W55j-QBhsQLdmHQ1BU-rLbjj_Nf-Ju04Y1972g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Mon, 14 Jul 2014 15:28:23 -0700

> On Mon, Jul 14, 2014 at 3:13 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Sun, 13 Jul 2014 17:12:54 -0700
>>
>>>  void ovs_vport_free(struct vport *vport)
>>>  {
>>> +     kfree((struct vport_portids __force *)vport->upcall_portids);
>>
>> This cast is ugly and never correct for this situation, you need to
>> use rcu_dereference().
> 
> This function is called either from RCU callback or error path, So it is fine.
> I do not use rcu_dereference() since rcu_read lock is not held. To
> avoid rcu sparse checker warning the typecast is done.

You need to find a cleaner way to express this, it's too ugly.
