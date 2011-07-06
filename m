From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH v2 net-next af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Wed, 6 Jul 2011 17:45:20 -0400
Message-ID: <CAAsGZS67G8H5NLBxQTY88+T1cRQ3aiwBXK5qa8SJ_TbQ7xqvhw@mail.gmail.com>
References: <1308708650-25509-2-git-send-email-loke.chetan@gmail.com>
	<20110701.153633.267893668051099806.davem@davemloft.net>
	<CAAsGZS5vvmb_qX+cG507=hU_+kwnowEEojXGNMt5ShEZ9+ZeAA@mail.gmail.com>
	<20110705.080123.2174577714045488116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110705.080123.2174577714045488116.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 5, 2011 at 11:01 AM, David Miller <davem@davemloft.net> wrote:

>
> That issue only exists because you haven't defined a common header
> struct that the current, and all future, block descriptor variants can
> include at the start of their definitions.

what's common today may not be common tomorrow. After much thinking I
decided to not provide a generic header because I wouldn't want to
enforce anything.

new format:

union bd_header_u {
       /* renamed struct bd_v1 to hdr_v1 */
       struct hdr_v1 h1;
} __attribute__ ((__packed__));

struct block_desc {
       __u16 version;
       __u16 offset_to_priv;
       union bd_header_u hdr;
} __attribute__ ((__packed__));

Is this ok with you?


>
> Use real data structures, not opaque "offset+size" poking into the
> descriptors.
>
Used to writing firmware APIs. APIs use words/bytes so that they can
be interpreted by firmware folks too.

Chetan Loke
