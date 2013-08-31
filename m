From: Hillf Danton <dhillf@gmail.com>
Subject: Re: 3.11-rc7:BUG: soft lockup
Date: Sat, 31 Aug 2013 11:25:03 +0800
Message-ID: <CAJd=RBCT6dbLwX6z+1LxCvJ9-NOYQRe0zzBkEQosFgLvNgg4bg@mail.gmail.com>
References: <522055D7.70002@gmail.com>
	<CAM_iQpW3F=inR0y6GFE64OgkhKSdzF-trrZamgThXTiyOYYmBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Baoquan He <baoquan.he@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:36715 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab3HaDZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 23:25:04 -0400
In-Reply-To: <CAM_iQpW3F=inR0y6GFE64OgkhKSdzF-trrZamgThXTiyOYYmBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 30, 2013 at 8:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Cc'ing netdev
>
> On Fri, Aug 30, 2013 at 4:20 PM, Baoquan He <baoquan.he@gmail.com> wrote:
>> Hi,
>>
>> I tried the 3.11.0-rc7+ on x86_64, and after bootup, the soft lockup bug
>> happened.
>>
>> [   48.895000] BUG: soft lockup - CPU#1 stuck for 22s! [ebtables:444]
>> [   48.901191] Modules linked in: bnep(F) bluetooth(F) ebtables(F)
>> ip6table_filter(F) ip6_tables(F) rfkill(F) snd_hda_intel(F+)
>> snd_hda_codec(F) snd_hwdep(F) snd_seq(F) sn)
>> [   48.950034] CPU: 1 PID: 444 Comm: ebtables Tainted: GF     D
>> 3.11.0-rc7+ #1
>> [   48.957433] Hardware name: Hewlett-Packard HP Z420 Workstation/1589,
>> BIOS J61 v01.02 03/09/2012
>> [   48.966131] task: ffff88040c2dc650 ti: ffff8804187d2000 task.ti:
>> ffff8804187d2000
>> [   48.973610] RIP: 0010:[<ffffffff812e57a7>]  [<ffffffff812e57a7>]
>> strcmp+0x27/0x40
>> [   48.981119] RSP: 0018:ffff8804187d3db8  EFLAGS: 00000246
>> [   48.986430] RAX: 0000000000000000 RBX: 00007fffda942730 RCX:
>> ffff8804187d3fd8
>> [   48.993566] RDX: 0000000000000000 RSI: ffff8804187d3e01 RDI:
>> ffffffff81cb8a39
>> [   49.000707] RBP: ffff8804187d3db8 R08: 00000000fffffff2 R09:
>> 0000000000000000
>> [   49.007841] R10: 0000000000000163 R11: 0000000000000000 R12:
>> ffffffff8128300c
>> [   49.014972] R13: ffff8804187d3d98 R14: ffff8804187d3ef4 R15:
>> 0000000000000004
>> [   49.022112] FS:  00007faab6589740(0000) GS:ffff88042fc80000(0000)
>> knlGS:0000000000000000
>> [   49.030194] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   49.035942] CR2: 0000003f0d810414 CR3: 000000040d2cc000 CR4:
>> 00000000000407e0
>> [   49.043077] Stack:
>> [   49.045096]  ffff8804187d3de8 ffffffffa0249674 0000000000000080
>> ffffffff81cb8180
>> [   49.052559]  00007fffda942730 ffff8804187d3ef4 ffff8804187d3ea0
>> ffffffffa02497a9
>> [   49.060020]  0000000000000000 00007265746c6966 0000003f0d7b92c0
>> 00007fffda942850
>> [   49.067487] Call Trace:
>> [   49.069949]  [<ffffffffa0249674>]
>> find_inlist_lock.constprop.16+0x54/0x100 [ebtables]
>> [   49.077779]  [<ffffffffa02497a9>] do_ebt_get_ctl+0x89/0x1d0 [ebtables]
>> [   49.084306]  [<ffffffff81551ca8>] nf_getsockopt+0x68/0x90
>> [   49.089717]  [<ffffffff81560d40>] ip_getsockopt+0x80/0xa0
>> [   49.095113]  [<ffffffff815835c5>] raw_getsockopt+0x25/0x50
>> [   49.100588]  [<ffffffff8150ddd4>] sock_common_getsockopt+0x14/0x20
>> [   49.106766]  [<ffffffff8150d208>] SyS_getsockopt+0x68/0xd0
>> [   49.112257]  [<ffffffff8162c682>] system_call_fastpath+0x16/0x1b
>> [   49.118260] Code: 00 00 00 00 55 48 89 e5 eb 0e 66 2e 0f 1f 84 00 00
>> 00 00 00 84 c0 74 1c 48 83 c7 01 0f b6 47 ff 48 83 c6 01 3a 46 ff 74 eb
>> 19 c0 <83> c8 01 5d c3 0f 1
>> [   76.925880] BUG: soft lockup - CPU#1 stuck for 22s! [ebtables:444]
>> [   76.932069] Modules linked in: bnep(F) bluetooth(F) ebtables(F)
>> ip6table_filter(F) ip6_tables(F) rfkill(F) snd_hda_intel(F+)
>> snd_hda_codec(F) snd_hwdep(F) snd_seq(F) sn)
>> [   76.980847] CPU: 1 PID: 444 Comm: ebtables Tainted: GF     D
>> 3.11.0-rc7+ #1
>> [   76.988245] Hardware name: Hewlett-Packard HP Z420 Workstation/1589,
>> BIOS J61 v01.02 03/09/2012
>> [   76.996940] task: ffff88040c2dc650 ti: ffff8804187d2000 task.ti:
>> ffff8804187d2000
>> [   77.004426] RIP: 0010:[<ffffffff812e5784>]  [<ffffffff812e5784>]
>> strcmp+0x4/0x40
>> [   77.011849] RSP: 0018:ffff8804187d3db8  EFLAGS: 00000212
>> [   77.017163] RAX: 0000000000000001 RBX: 00007fffda942730 RCX:
>> ffff8804187d3fd8
>> [   77.024304] RDX: 0000000000000000 RSI: ffff8804187d3e00 RDI:
>> ffffffff81cb8a38
>> [   77.031434] RBP: ffff8804187d3db8 R08: 00000000fffffff2 R09:
>> 0000000000000000
>> [   77.038566] R10: 0000000000000163 R11: 0000000000000000 R12:
>> ffffffff8128300c
>> [   77.045699] R13: ffff8804187d3d98 R14: ffff8804187d3ef4 R15:
>> 0000000000000004
>> [   77.052842] FS:  00007faab6589740(0000) GS:ffff88042fc80000(0000)
>> knlGS:0000000000000000
>> [   77.060934] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   77.066668] CR2: 0000003f0d810414 CR3: 000000040d2cc000 CR4:
>> 00000000000407e0
>> [   77.073799] Stack:
>> [   77.075818]  ffff8804187d3de8 ffffffffa0249674 0000000000000080
>> ffffffff81cb8180
>> [   77.083287]  00007fffda942730 ffff8804187d3ef4 ffff8804187d3ea0
>> ffffffffa02497a9
>> [   77.090749]  0000000000000000 00007265746c6966 0000003f0d7b92c0
>> 00007fffda942850
>> [   77.098215] Call Trace:
>> [   77.100668]  [<ffffffffa0249674>]
>> find_inlist_lock.constprop.16+0x54/0x100 [ebtables]
>> [   77.108500]  [<ffffffffa02497a9>] do_ebt_get_ctl+0x89/0x1d0 [ebtables]
>> [   77.115035]  [<ffffffff81551ca8>] nf_getsockopt+0x68/0x90
>> [   77.120438]  [<ffffffff81560d40>] ip_getsockopt+0x80/0xa0
>> [   77.125845]  [<ffffffff815835c5>] raw_getsockopt+0x25/0x50
>> [   77.131328]  [<ffffffff8150ddd4>] sock_common_getsockopt+0x14/0x20
>> [   77.137515]  [<ffffffff8150d208>] SyS_getsockopt+0x68/0xd0
>> [   77.143011]  [<ffffffff8162c682>] system_call_fastpath+0x16/0x1b
>> [   77.149019] Code: 0f 1f 80 00 00 00 00 48 83 c6 01 0f b6 4e ff 48 83
>> c2 01 84 c9 88 4a ff 75 ed 5d c3 66 66 2e 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 <eb> 0e 66 2e 0f 1f 8
>
>
> Does the following patch help?
>
>
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index ac78024..4a0ec8f 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1503,6 +1503,10 @@ static int do_ebt_get_ctl(struct sock *sk, int
> cmd, void __user *user, int *len)
>         if (copy_from_user(&tmp, user, sizeof(tmp)))
>                 return -EFAULT;
>
> +       if (memscan(tmp.name, '\0', EBT_TABLE_MAXNAMELEN) ==
> +                   (tmp.name + EBT_TABLE_MAXNAMELEN))
> +               return -EINVAL;
> +
>         t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
>         if (!t)
>                 return ret;
> --
>
release lock!!

--- a/net/bridge/netfilter/ebtables.c Sat Aug 31 11:12:54 2013
+++ b/net/bridge/netfilter/ebtables.c Sat Aug 31 11:15:24 2013
@@ -332,8 +332,10 @@ find_inlist_lock_noload(struct list_head
  return NULL;

  list_for_each_entry(e, head, list) {
- if (strcmp(e->name, name) == 0)
+ if (strcmp(e->name, name) == 0) {
+ mutex_unlock(mutex);
  return e;
+ }
  }
  *error = -ENOENT;
  mutex_unlock(mutex);
--
