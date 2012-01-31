From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Mon, 30 Jan 2012 20:22:03 -0800
Message-ID: <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327963304-24828-1-git-send-email-asharma@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 2:41 PM, Arun Sharma <asharma@fb.com> wrote:
> Some of our machines were reporting:
>
> TCP: too many of orphaned sockets
>
> even when the number of orphaned sockets was well below the
> limit.
>
> We print a different message depending on whether we're out
> of TCP memory or there are too many orphan sockets.

This patch mentions pairs of messages that are almost the same, but
not quite.  If they're supposed to be different, I'd suggest making
them clearly different.  As it is, the differences look like careless
mistakes:

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk=
(KERN_INFO "TCP: too many of orphaned "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 "sockets\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "TCP: =
too many orphaned sockets\n");

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_INFO "TCP: out of memory. "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0"Consider tuning tcp_mem\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_INFO "Out =
of socket memory\n");

"too many orphaned sockets" is better English usage than "too many of .=
=2E."

Bjorn
