From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 01/11] openvswitch: Allow each vport to have an array of 'port_id's.
Date: Mon, 14 Jul 2014 15:28:23 -0700
Message-ID: <CALnjE+pSnhG4W55j-QBhsQLdmHQ1BU-rLbjj_Nf-Ju04Y1972g@mail.gmail.com>
References: <1405296774-3648-1-git-send-email-pshelar@nicira.com>
	<20140714.151337.573086784322485064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Alex Wang <alexw@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:47329 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756976AbaGNW2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:28:24 -0400
Received: by mail-vc0-f179.google.com with SMTP id id10so8485524vcb.38
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 15:28:23 -0700 (PDT)
In-Reply-To: <20140714.151337.573086784322485064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 3:13 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Sun, 13 Jul 2014 17:12:54 -0700
>
>>  void ovs_vport_free(struct vport *vport)
>>  {
>> +     kfree((struct vport_portids __force *)vport->upcall_portids);
>
> This cast is ugly and never correct for this situation, you need to
> use rcu_dereference().

This function is called either from RCU callback or error path, So it is fine.
I do not use rcu_dereference() since rcu_read lock is not held. To
avoid rcu sparse checker warning the typecast is done.
