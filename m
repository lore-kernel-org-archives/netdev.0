From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 12:26:25 +0200
Message-ID: <CANq1E4TCW_bnbTYacnfJHRvZAcOYnSgqxytHk26EaWeQKkphGA@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	<1404980258-30853-11-git-send-email-teg@jklm.no>
	<87pphdh85q.fsf@nemi.mork.no>
	<CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

>> The same goes for NET_NAME_USER and NET_NAME_RENAMED. These are the same
>> from a kernel point of view.
>
> You mean to collapse the two, and just label renamed interfaces
> NET_NAME_USER instead?

I have no real objections to merging NAME_USER and NAME_RENAMED. Both
values imply that there is a user-space authority that applied some
kind of rules to the naming-scheme. Therefore, anyone reacting to
those names should better treat them equally and fix the
naming-authority instead of overwriting it.

However, at the same time I think there's no real harm in keeping them
separate, either. My original thinking was to provide a second layer
for anyone overwriting system defaults. For instance, if there's a
user-space given name and a system-administrator wants to rename that
for administrative purposes, they can safely match on NAME_USER and be
sure, it wasn't renamed, yet. If it is set to NAME_RENAMED, though,
then the administrator has some kind of safety-net that tells him he
already has a rule that renamed the device and he shouldn't add
another one (like placing one in initrd and one in the real root).

Anyhow, if no-one cares about that, please go ahead and squash both
into NET_NAME_USER.

Thanks
David
