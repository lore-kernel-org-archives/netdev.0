From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Subject: Re: [RFC PATCH net 1/2] [BUGFIX] bonding: use local function pointer
 of bond->recv_probe in bond_handle_frame
Date: Tue, 11 Oct 2011 22:02:11 +0900
Message-ID: <4E943E53.6010601@hitachi.com>
References: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp> <20111007124954.7089.9776.stgit@ltc219.sdl.hitachi.co.jp> <CAM_iQpXZmX2GPb99tF7xMEup52o8AfeUi+0awvHr7C9LVWTjEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXZmX2GPb99tF7xMEup52o8AfeUi+0awvHr7C9LVWTjEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi WANG Cong

Thank you for your comments.

(2011/10/07 22:24), Am=C3=A9rico Wang wrote:
> On Fri, Oct 7, 2011 at 8:49 PM, Mitsuo Hayasaka
> <mitsuo.hayasaka.hu@hitachi.com> wrote:
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
>=20
> Hmm, I don't doubt it can fix the problem, I am wondering if
> bond->recv_probe should be protected by bond->lock...

Indeed, in general any resources should be protected from the asynchron=
ous
workers.

At first, I thought it should be handled with lock protection, as well.
However, I guess that using bond->lock on this kind of hot-path may
introduces unnecessary overhead. In addition, this code works well
without the strict lock protection. So, I think this change is the
right way to fix it.

Thanks.
