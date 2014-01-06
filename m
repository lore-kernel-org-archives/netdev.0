From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/11] use ether_addr_equal_64bits
Date: Mon, 06 Jan 2014 07:18:42 -0800
Message-ID: <1389021522.12212.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	 <1388429761.4410.1.camel@jlt4.sipsolutions.net>
	 <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	 <1388438724.4573.2.camel@jlt4.sipsolutions.net>
	 <20131230215701.GA4938@khazad-dum.debian.net>
	 <1388445188.18164.0.camel@jlt4.sipsolutions.net>
	 <CANUX_P0PX1g8uHJUHYoB4UyMMgbtLas0_pf4TYrLTgND5V37rg@mail.gmail.com>
	 <CAMuHMdXZQO7jj+V2mMyyLgDoz6iSLJ25+55Yow-Acb1=tE5sMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <egrumbach@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXZQO7jj+V2mMyyLgDoz6iSLJ25+55Yow-Acb1=tE5sMg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-06 at 10:24 +0100, Geert Uytterhoeven wrote:

> Thanks to this discussion, my eye fell on:
> 
> static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
> {
>         const u16 *a = (const u16 *) addr1;
>         const u16 *b = (const u16 *) addr2;
> 
>         BUILD_BUG_ON(ETH_ALEN != 6);
>         return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
> }
> 
> What if addr1 or addr2 are odd, and this is running on an architecture that
> doesn't support unaligned accesses at all?? Have we been lucky forever?

This function always had the guarantee of u16 alignment.

No protocol ever included an ether address at an odd alignment, and
drivers always make sure a frame is at least 2-byte aligned.

Its kind of obvious for networking people, Stephen did not mention this
property in commit 360ac8e2f1a38c34
