From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v1 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Wed, 06 Mar 2013 15:53:52 +0100
Message-ID: <87ppzcmven.fsf@nemi.mork.no>
References: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
	<1362565557-15884-5-git-send-email-ming.lei@canonical.com>
	<877glkohu2.fsf@nemi.mork.no>
	<CACVXFVMS4JNphgcU4oy7VQ1S6AoXQUcpRT2ODE_DP79AsnAY4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <CACVXFVMS4JNphgcU4oy7VQ1S6AoXQUcpRT2ODE_DP79AsnAY4g@mail.gmail.com>
	(Ming Lei's message of "Wed, 6 Mar 2013 21:48:19 +0800")
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei@canonical.com> writes:
> On Wed, Mar 6, 2013 at 8:04 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>
>> I believe the correct here is to document the fact that we require t=
he
>> subdriver->suspend() callback to always return 0 if !PMSG_IS_AUTO(me=
ssage).
>> That is best done with a comment. No need to add any redundant code.
>
> Considered that the subdriver might change its return value in future=
,

Not likely.  It lives under the exact same restrictions as a standalone
USB interface driver.  If it starts returning something else, then this
driver should probably do so as well.

> how about just add the below comment?
>
>         /* TODO: resume() might need to handle suspend failure from s=
ubdriver */

OK with me if that includes dropping the redundant code change.

Note that the same issue and comment applies to the usbnet_suspend()
call as well.  We currently rely on both calls to always return 0 on
system suspend.  Which they are guaranteed to do, because they are both
directly used as .suspend callbacks in other USB interface drivers.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
