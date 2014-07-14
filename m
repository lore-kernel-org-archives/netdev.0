From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 01/11] openvswitch: Allow each vport to have an array of 'port_id's.
Date: Mon, 14 Jul 2014 16:48:29 -0700
Message-ID: <CALnjE+rLksz68ybjvU+bzExsbDo2evEfXHv5dEc6ixTBzWrFEw@mail.gmail.com>
References: <1405296774-3648-1-git-send-email-pshelar@nicira.com>
	<20140714.151337.573086784322485064.davem@davemloft.net>
	<CALnjE+pSnhG4W55j-QBhsQLdmHQ1BU-rLbjj_Nf-Ju04Y1972g@mail.gmail.com>
	<20140714.161726.579481406574025687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Alex Wang <alexw@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:54391 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750950AbaGNXsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 19:48:30 -0400
Received: by mail-vc0-f169.google.com with SMTP id hu12so3729494vcb.28
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 16:48:29 -0700 (PDT)
In-Reply-To: <20140714.161726.579481406574025687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 4:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Mon, 14 Jul 2014 15:28:23 -0700
>
>> On Mon, Jul 14, 2014 at 3:13 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Pravin B Shelar <pshelar@nicira.com>
>>> Date: Sun, 13 Jul 2014 17:12:54 -0700
>>>
>>>>  void ovs_vport_free(struct vport *vport)
>>>>  {
>>>> +     kfree((struct vport_portids __force *)vport->upcall_portids);
>>>
>>> This cast is ugly and never correct for this situation, you need to
>>> use rcu_dereference().
>>
>> This function is called either from RCU callback or error path, So it is fine.
>> I do not use rcu_dereference() since rcu_read lock is not held. To
>> avoid rcu sparse checker warning the typecast is done.
>
> You need to find a cleaner way to express this, it's too ugly.

ok, I will add another rcu_callback for freeing upcall_portids.

Thanks.
