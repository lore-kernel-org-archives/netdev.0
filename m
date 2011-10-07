From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 2/2] [BUGFIX] bonding: use flush_delayed_work_sync
 in bond_close
Date: Fri, 7 Oct 2011 21:34:32 +0800
Message-ID: <CAM_iQpX+wfpkNiRfom148FEuSTqH_S3OiY31e+uCcTiuCx4etg@mail.gmail.com>
References: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp>
	<20111007125006.7089.9539.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111007125006.7089.9539.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 7, 2011 at 8:50 PM, Mitsuo Hayasaka
<mitsuo.hayasaka.hu@hitachi.com> wrote:
> The bond_close() calls cancel_delayed_work() to cancel delayed works.
> It, however, cannot cancel works that were already queued in workqueue.
> The bond_open() initializes work->data, and proccess_one_work() refers
> get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL when
> work->data has been initialized. Thus, a panic occurs.
>
> This patch uses flush_delayed_work_sync() instead of cancel_delayed_work()
> in bond_close(). It cancels delayed timer and waits for work to finish
> execution. So, it can avoid the null pointer dereference due to the
> parallel executions of proccess_one_work() and initializing proccess
> of bond_open().
>
> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>

Makes sense,

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks!
