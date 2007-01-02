From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/flow.c: compare data with memcmp
Date: Tue, 02 Jan 2007 15:36:26 -0800 (PST)
Message-ID: <20070102.153626.14976011.davem@davemloft.net>
References: <20061231.123715.115911390.davem@davemloft.net>
	<80ec54e90612312347w2b906e5eg725a7761110c6897@mail.gmail.com>
	<80ec54e90701010116u27d02341kb2be785f17f18e3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964913AbXABXg2@vger.kernel.org>
To: daniel.marjamaki@gmail.com
In-Reply-To: <80ec54e90701010116u27d02341kb2be785f17f18e3d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Daniel_Marjam=E4ki" <daniel.marjamaki@gmail.com>
Date: Mon, 1 Jan 2007 10:16:02 +0100

> I have done a little testing on my own. My results is that memcpy is
> many times faster even with aligned data.

Your test program doesn't make any measurements, from where did
you get these "results"?

Also, your test program is broken because in the memcmp() case GCC
totally optimizes away the call to memcmp() because it can see the
comparison data at compile time and therefore it computes the memcmp()
result at compile time.  There are no memcmp() calls made at all by
your program.

You should look at the assembler code emitted by a test program
that is measuring performance, in detail, to make sure the test
program really is doing what you think it is.
