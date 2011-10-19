From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use local function pointer
 of bond->recv_probe in bond_handle_frame
Date: Wed, 19 Oct 2011 00:03:11 -0400 (EDT)
Message-ID: <20111019.000311.1490092497677136273.davem@davemloft.net>
References: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: mitsuo.hayasaka.hu@hitachi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Date: Thu, 13 Oct 2011 11:04:29 +0900

> The bond->recv_probe is called in bond_handle_frame() when
> a packet is received, but bond_close() sets it to NULL. So,
> a panic occurs when both functions work in parallel.
> 
> Why this happen:
> After null pointer check of bond->recv_probe, an sk_buff is
> duplicated and bond->recv_probe is called in bond_handle_frame.
> So, a panic occurs when bond_close() is called between the
> check and call of bond->recv_probe.
> 
> Patch:
> This patch uses a local function pointer of bond->recv_probe
> in bond_handle_frame(). So, it can avoid the null pointer
> dereference.
> 
> 
> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>

Bonding folks please review this, thanks.
