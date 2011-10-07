From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 1/2] [BUGFIX] bonding: use local function pointer
 of bond->recv_probe in bond_handle_frame
Date: Fri, 7 Oct 2011 21:24:51 +0800
Message-ID: <CAM_iQpXZmX2GPb99tF7xMEup52o8AfeUi+0awvHr7C9LVWTjEg@mail.gmail.com>
References: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp>
	<20111007124954.7089.9776.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111007124954.7089.9776.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 7, 2011 at 8:49 PM, Mitsuo Hayasaka
<mitsuo.hayasaka.hu@hitachi.com> wrote:
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

Hmm, I don't doubt it can fix the problem, I am wondering if
bond->recv_probe should be protected by bond->lock...
