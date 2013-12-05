From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: fix a BUG_ON on triggered by setting max_autoclose
 to
Date: Thu, 05 Dec 2013 11:00:00 -0500
Message-ID: <52A0A300.3010409@gmail.com>
References: <529DADE5.4040701@huawei.com> <529E0242.6020008@gmail.com> <20131203181822.GB3251@neilslaptop.think-freely.org> <529E4BFA.8020501@gmail.com> <20131204132843.GB4096@hmsreliant.think-freely.org> <529F4027.30308@gmail.com> <20131204185608.GC4096@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wang Weidong <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:42692 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab3LEQAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:00:07 -0500
In-Reply-To: <20131204185608.GC4096@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 01:56 PM, Neil Horman wrote:
> On Wed, Dec 04, 2013 at 09:45:59AM -0500, Vlad Yasevich wrote:
>> On 12/04/2013 08:28 AM, Neil Horman wrote:
>>> On Tue, Dec 03, 2013 at 04:24:10PM -0500, Vlad Yasevich wrote:
>>>> On 12/03/2013 01:18 PM, Neil Horman wrote:
>>>>> On Tue, Dec 03, 2013 at 11:09:38AM -0500, Vlad Yasevich wrote:
>>>>>> On 12/03/2013 05:09 AM, Wang Weidong wrote:
>>>>>>> since 2692ba61, add the max_autoclose to sysctl. when I setted the
>>>>>>> max_autoclose to 0. Just do the test_autoclose, it will trigger that:
>>>>>>>
>>>>>>> [  608.056238] ------------[ cut here ]------------
>>>>>>> [  608.056244] kernel BUG at /home/wwd/work/linux/net/sctp/sm_sideeffect.c:1488!
>>>>>>> [  608.056250] invalid opcode: 0000 [#1] SMP
>>>>>>> [  608.056254] Modules linked in: md5 sctp(O) crc32c libcrc32c edd fuse loop dm_mod ipv6 8139too sg 8139cp mii i2c_piix4 i2c_core virtio_balloon intel_agp virtio_pci virtio_ring sr_mod cdrom rtc_cmos joydev hid_generic intel_gtt virtio floppy pcspkr button ext3 jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore sd_mod usb_common crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_emc scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh ata_generic ata_piix libata scsi_mod [last unloaded: sctp]
>>>>>>> [  608.056310] CPU: 5 PID: 4517 Comm: test_autoclose Tainted: G  R        O 3.13.0-rc1-0.27-default+ #2
>>>>>>> [  608.056315] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
>>>>>>> [  608.056319] task: ffff8800372f5590 ti: ffff8800db882000 task.ti: ffff8800db882000
>>>>>>> [  608.056323] RIP: 0010:[<ffffffffa033e350>]  [<ffffffffa033e350>] sctp_cmd_interpreter+0x1010/0x1070 [sctp]
>>>>>>> [  608.056339] RSP: 0018:ffff880116f43928  EFLAGS: 00010246
>>>>>>> [  608.056343] RAX: 0000000000000009 RBX: ffff880116f43ab8 RCX: 0000000000000009
>>>>>>> [  608.056349] RDX: 0000000000000003 RSI: 0000000000000000 RDI: ffff880116f43a88
>>>>>>> [  608.056353] RBP: ffff880116f439d8 R08: 0000000000002029 R09: 0000000000000001
>>>>>>> [  608.056357] R10: 0000000000000000 R11: 0000000000000005 R12: ffff8800db7c9150
>>>>>>> [  608.056361] R13: 0000000000000000 R14: ffff8800db7c9000 R15: 0000000000000001
>>>>>>> [  608.056365] FS:  00007f942d71c700(0000) GS:ffff880116f40000(0000) knlGS:0000000000000000
>>>>>>> [  608.056370] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>>>> [  608.056373] CR2: 00007f942d324d90 CR3: 00000000db094000 CR4: 00000000000006e0
>>>>>>> [  608.056382] Stack:
>>>>>>> [  608.056384]  0000000000000018 ffff880116f43988 ffff8800da569600 000000010000000a
>>>>>>> [  608.056391]  ffff880037265e40 0000000016f43988 ffff880116f439e8 0000000000000000
>>>>>>> [  608.056397]  ffffffffa0365101 0000000000000000 ffff880116f43a28 ffffffff812b7739
>>>>>>> [  608.056403] Call Trace:
>>>>>>> [  608.056406]  <IRQ>
>>>>>>> [  608.056409]
>>>>>>> [  608.056421]  [<ffffffff812b7739>] ? __dynamic_pr_debug+0x69/0x80
>>>>>>> [  608.056432]  [<ffffffff81097c6d>] ? trace_hardirqs_off+0xd/0x10
>>>>>>> [  608.056442]  [<ffffffff814e7258>] ? _raw_spin_unlock_irqrestore+0x58/0x60
>>>>>>> [  608.056451]  [<ffffffffa033e3e6>] sctp_side_effects+0x36/0x130 [sctp]
>>>>>>> [  608.056459]  [<ffffffffa033e5c7>] sctp_do_sm+0xe7/0x210 [sctp]
>>>>>>> [  608.056470]  [<ffffffffa0359860>] ? sctp_rcv+0x780/0x780 [sctp]
>>>>>>> [  608.056479]  [<ffffffffa0340a5f>] sctp_endpoint_bh_rcv+0x10f/0x220 [sctp]
>>>>>>> [  608.056489]  [<ffffffffa0349991>] sctp_inq_push+0x41/0x60 [sctp]
>>>>>>> [  608.056498]  [<ffffffffa03597b5>] sctp_rcv+0x6d5/0x780 [sctp]
>>>>>>> [  608.056508]  [<ffffffffa0358e00>] ? sctp_csum_combine+0x10/0x10 [sctp]
>>>>>>> [  608.056518]  [<ffffffffa0358df0>] ? sctp_v4_err+0x240/0x240 [sctp]
>>>>>>> [  608.056528]  [<ffffffff8145b8a4>] ip_local_deliver_finish+0xf4/0x270
>>>>>>> [  608.056533]  [<ffffffff8145b7f0>] ? ip_local_deliver_finish+0x40/0x270
>>>>>>> [  608.056538]  [<ffffffff8145b690>] ip_local_deliver+0x80/0x90
>>>>>>> [  608.056543]  [<ffffffff8145bbd3>] ip_rcv_finish+0x1b3/0x600
>>>>>>> [  608.056547]  [<ffffffff8145ba20>] ? ip_local_deliver_finish+0x270/0x270
>>>>>>> [  608.056552]  [<ffffffff8145b04f>] NF_HOOK+0x2f/0x70
>>>>>>> [  608.056565]  [<ffffffff81425853>] ? __netif_receive_skb_core+0x113/0x7a0
>>>>>>> [  608.056570]  [<ffffffff8145b365>] ip_rcv+0x2d5/0x3b0
>>>>>>> [  608.056575]  [<ffffffff81425e3f>] __netif_receive_skb_core+0x6ff/0x7a0
>>>>>>> [  608.056580]  [<ffffffff81425853>] ? __netif_receive_skb_core+0x113/0x7a0
>>>>>>> [  608.056585]  [<ffffffff81426108>] ? process_backlog+0x1a8/0x1c0
>>>>>>> [  608.056590]  [<ffffffff81425f0b>] __netif_receive_skb+0x2b/0x80
>>>>>>> [  608.056595]  [<ffffffff81426018>] process_backlog+0xb8/0x1c0
>>>>>>> [  608.056600]  [<ffffffff8142695c>] net_rx_action+0x11c/0x240
>>>>>>> [  608.056607]  [<ffffffff81050e18>] __do_softirq+0x118/0x290
>>>>>>> [  608.056615]  [<ffffffff814f0e0c>] do_softirq_own_stack+0x1c/0x30
>>>>>>> [  608.056618]  <EOI>
>>>>>>> [  608.056620]
>>>>>>> [  608.056623]  [<ffffffff81050bd5>] do_softirq+0x65/0x70
>>>>>>> [  608.056629]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
>>>>>>> [  608.056635]  [<ffffffff810518c3>] local_bh_enable_ip+0xb3/0xc0
>>>>>>> [  608.056640]  [<ffffffff814e71af>] _raw_spin_unlock_bh+0x2f/0x40
>>>>>>> [  608.056645]  [<ffffffff8140fddc>] release_sock+0x8c/0xa0
>>>>>>> [  608.056654]  [<ffffffffa0354c08>] sctp_sendmsg+0x3a8/0xcc0 [sctp]
>>>>>>> [  608.056661]  [<ffffffff8129924a>] ? number+0x33a/0x360
>>>>>>> [  608.056667]  [<ffffffff81497c3c>] inet_sendmsg+0x9c/0x100
>>>>>>> [  608.056672]  [<ffffffff81497ba0>] ? inet_recvmsg+0x110/0x110
>>>>>>> [  608.056679]  [<ffffffff8140a387>] sock_sendmsg+0x97/0xc0
>>>>>>> [  608.056690]  [<ffffffff8114caae>] ? might_fault+0x3e/0x90
>>>>>>> [  608.056695]  [<ffffffff8114caae>] ? might_fault+0x3e/0x90
>>>>>>> [  608.056700]  [<ffffffff81417a73>] ? verify_iovec+0x53/0x100
>>>>>>> [  608.056705]  [<ffffffff8140abb6>] ___sys_sendmsg+0x416/0x420
>>>>>>> [  608.056710]  [<ffffffff81151af6>] ? __do_fault+0x216/0x510
>>>>>>> [  608.056715]  [<ffffffff814eaf74>] ? __do_page_fault+0x2b4/0x4a0
>>>>>>> [  608.056720]  [<ffffffff81095c9e>] ? up_read+0x1e/0x40
>>>>>>> [  608.056724]  [<ffffffff814eaf74>] ? __do_page_fault+0x2b4/0x4a0
>>>>>>> [  608.056729]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
>>>>>>> [  608.056733]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
>>>>>>> [  608.056741]  [<ffffffff8109bb5d>] ? trace_hardirqs_on+0xd/0x10
>>>>>>> [  608.056746]  [<ffffffff81051875>] ? local_bh_enable_ip+0x65/0xc0
>>>>>>> [  608.056751]  [<ffffffff8140ad94>] __sys_sendmsg+0x44/0x80
>>>>>>> [  608.056756]  [<ffffffff8140ade4>] SyS_sendmsg+0x14/0x20
>>>>>>> [  608.056761]  [<ffffffff814ef5a2>] system_call_fastpath+0x16/0x1b
>>>>>>> -------------------------------------
>>>>>>>
>>>>>>> The reason is: In test_autoclose set the autoclose to 5 not 0(default). So when
>>>>>>> we init the association, the (sctp_sock) sp->autoclose is not 0 while asoc's 
>>>>>>> timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] is 0.
>>>>>>> So when we process the COOKIE_ACK, the sctp_sf_do_5_1E_ca will be called, that
>>>>>>> will do that:
>>>>>>> 	if (asoc->autoclose) //asoc->autoclose is equal sp->autoclose
>>>>>>> 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
>>>>>>> 				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>>>>>>
>>>>>> this looks like a bug in how the timeout is being set.  The timeout
>>>>>> should be based on the association value, not some sysctl value.
>>>>>>
>>>>>> The typical socket option values go like this:
>>>>>>    socket value = starts at sysctl, changed by user.
>>>>>>    assoc value = starts at socket value, may be changed by user.
>>>>>>      any timer = starts at assoc value.
>>>>>>
>>>>>> this seems to be broken for autoclose.
>>>>>>
>>>>> Well, it is, but I think its a reasonable fix for the issue.  As I understand
>>>>> the description, the problem is that if autoclose is non-zero, and the default
>>>>> timeout is zero, then you'll get a BUG_ON halt because you need to set a timer
>>>>> that will expire immediately.  It seems reasonable to me to make a minimal
>>>>> default for the timeout to be non-zero, since it makes no sense to have a zero
>>>>> auto-close timeout.
>>>>
>>>> Yes, the default timeout is zero because the timeout is latched by the
>>>> sysctl value while the association value is not.  So, the association
>>>> value is now out-of-sync with what the system does and we end up lying
>>>> to the user when they do a getsockopt().
>>>>
>>> Thats not true, looking at the sctp_association_init code the timeout is
>>> defaulted to the minimum of the socket value and the maxium timeout sysctl
>>> value, the latter of which is defined as INT_MAX/HZ.  That seems reasonable to
>>> me in that an association latches both the timeout value and the enabled value
>>> from its parent socket at association init time (assoc->autoclose is assigned
>>> from sp->autoclose farther down in sctp_association_init).
>>
>> Right, so let's see what happens.  Let the sysctl value be set to 1.
>> The the socket is created and the option is used to set the value to 10.
>> Now, association is created and the timeout is latched to 1.
>> However, the autoclose value of the association is set to 10.  So now
>> we are lying to the user about our autoclose value!
>>
> I think thats not really a problem here.  The sysctl in question is designed to
> do exactly what you describe, and in your scenario above the user has change the
> sysctl from the default setting of MAX_INT/HZ to 1, so they know that the
> autocolse timeout is going to be limited.  I agree that the fact that getsockopt
> is going to return the value 10 instead of 1 is an irritant, but its never
> guaranteed to match what an associations actual timeout is, because, as you
> note, its latched at the time the association is created. Its no different than
> setting SOCK_AUTOCLOSE to 10, creating an association, then changing
> SOCK_AUTOCLOSE to 20.  The getsockopt operation will return 20 even though the
> existing association isn't using that as a timeout value.

Yes, the above is absolutely true for multiple calls to set autoclose.
However, for a single call to autoclose, we should return the value
currently in use, not the value that use the set and we may be ignoring
completely.

> 
>> This is what's causing the problem.  The timeout value is out of sync
>> what what the requested timeout value is.
>>
>> Now, if we latch the socket value correctly, then everything just starts
>> to work, even for sysctl value of 0, and we stop lying to the user on
>> getsockopt() calls.  This is the real bug that causing the BUG_ON.
>>
>>>
>>>> If we simply latch the socket value properly, then we would have to
>>>> worry about this at all.  If the socket value is latched at 0, then
>>>> autoclose is disabled.
>>>>
> Ok, so whats "correct" here?  Are you proposing that we remove the max_autoclose
> sysctl entirely, or shall we check the value passed into the autoclose
> setsockopt against the sysctl value, to ensure that users don't set a value
> larger than what the max specifies, lest we continue to 'lie' to them by letting
> them set a autoclose timeout larger than what we intend to set when we initalize
> an association? 

Yes, that's what we should do.  Essentially treat this similar to how
the stack SO_{SND|RCV}BUF.  Might even log a warning to say autoclose is
limited by sysctl.

> Regardless of what we do here, Theres still no guarantee that
> the socket level value will match any given association, and thats just the way
> it goes.
> 

That's ok, as long as it uses a valid value and the association timer is
set based on the value in the socket.

> What we should do, regardless, is remove assoc->autoclose entirely, and replace
> all references to it with references to
> asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]
> That way we use a single canonical place to test the autoclose value (since
> assoc->autoclose is only used as a boolean test anyway).  Writing it down and
> reading it back to myself, that may actually be congruent with what you mean
> when you say that we should latch the socket value properly.
>

That's fine to.  So we would have a socket value that is properly
limited by sysctl and returns to the user the value new association will
use.  We would also have the timer value in the association that is
initialized with the socket value.  The timer value of 0 means autoclose
is disabled.  Does that make sense to you?

-vlad

> Neil
> 
>>> We are latching the value properly from what I can see.  The problem is that the
>>> upper bound on the value we latch can be zero.  The only way this bug can occur
>>> is if net->sctp.max_autoclose is 0.  Note that I'm not talking about the timeout
>>> value itself, but its upper bound.  We shouldn't be allowed to set the autoclose
>>> timeout sysctl range to [0..0], it just doesn't make sense.  It should be at
>>> least [0..1], and the socket autoclose value can range properly within that.
>>> From what I see, thats what this patch does.
>>
>> We don't allow the sysctl range of [0..0].  We allow the range of
>> [0..max_autoclose_max].  This patch tries to change the range to
>> [1..max_autoclose_max].  This may be a correct thing to do,
>> but it is another issue.  That fact this change fixes the BUG_ON is
>> a side-effect.  The real issue is in how we set set the timer value.
>>
>> -vlad
>>
>>>
>>> Neil
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
