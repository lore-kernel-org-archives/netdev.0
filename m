From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use local function pointer of bond->recv_probe in bond_handle_frame
Date: Wed, 19 Oct 2011 10:59:07 -0700
Message-ID: <26928.1319047147@death>
References: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp> <20111019.000311.1490092497677136273.davem@davemloft.net>
Cc: mitsuo.hayasaka.hu@hitachi.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com, eric.dumazet@gmail.com,
	xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20111019.000311.1490092497677136273.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
>Date: Thu, 13 Oct 2011 11:04:29 +0900
>
>> The bond->recv_probe is called in bond_handle_frame() when
>> a packet is received, but bond_close() sets it to NULL. So,
>> a panic occurs when both functions work in parallel.
>> 
>> Why this happen:
>> After null pointer check of bond->recv_probe, an sk_buff is
>> duplicated and bond->recv_probe is called in bond_handle_frame.
>> So, a panic occurs when bond_close() is called between the
>> check and call of bond->recv_probe.
>> 
>> Patch:
>> This patch uses a local function pointer of bond->recv_probe
>> in bond_handle_frame(). So, it can avoid the null pointer
>> dereference.
>> 
>> 
>> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: WANG Cong <xiyou.wangcong@gmail.com>
>
>Bonding folks please review this, thanks.
>

	Looks reasonable.  Even if by some quirk of timing the
recv_probe function ends up being entered after bond_close has
completed, it doesn't look like there is a risk of those functions
misbehaving (because bond_close doesn't deallocate the data structures).

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
