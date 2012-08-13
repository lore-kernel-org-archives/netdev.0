From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 13 Aug 2012 15:33:24 +0200
Message-ID: <CACRpkdZXZur4QgkDrCbo1zyyEod1qoCb_2QXg_Syai2XAMMUrg@mail.gmail.com>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
	<1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
	<20120807183809.GC26990@kroah.com>
	<F45880696056844FA6A73F415B568C695B0E796A03@EXDCVYMBSTM006.EQ1STM.local>
	<20120808133748.GA14459@kroah.com>
	<F45880696056844FA6A73F415B568C695B0E797048@EXDCVYMBSTM006.EQ1STM.local>
	<20120809123855.1ba0fffb@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arun MURTHY <arun.murthy@stericsson.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120809123855.1ba0fffb@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 9, 2012 at 1:38 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> Maybe tty can do this, but want to have all modem related  separately.
>> There are many such hardware and many drivers coming up in near future.
>
> tty can't do all this. We have similar things with stuff like CAIF. Modem
> has gone from pretending to be a serial port (tty) to appearing as a
> smart multi-function controller.

I second this, I plead guilty to suggesting to use "modem_shm"
as a layer below because things like CAIF and Phonet are just
growing and growing.

Sure, many of them can emulate AT commands, but that is
not their native tongue, and increasingly any AT command parser
is constrained to userspace which in turn constructs the actually
intended IPC command sequency for doing ATDT555784629568.

These modems are not talking anything resembling a line
discipline, they have their own binary protocol and above are
protocols like CAIF and Phonet talking to the modem, including
IPC to processes running on the other sides, with states.

Sjur is currently working on a future platform where we'll attempt
to bring things closer to existing Linux frameworks using virtio
rings and rpmesg also on the modem side, but the modems Arun
are working on are already deployed with this type of firmware
talking some other IPC lingo.

Yours,
Linus Walleij
