From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 03:40:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.034039.26980950.davem@redhat.com>
References: <20030609101302.GA9643@wotan.suse.de>
	<20030609.031341.77044985.davem@redhat.com>
	<20030609.194046.29425359.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru,
   Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20030609.194046.29425359.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
   Date: Mon, 09 Jun 2003 19:40:46 +0900 (JST)
   
   Ok, how about this?

The memset_tail thing is unnecessary, and better to put the
non-zero objects at the beginning then you can go.

	 memset(dst->${FIRST_ZERO_MEMBER}, 0,
	        ops->entry_size -
		offsetof(struct dst_entry, ${FIRST_ZERO_MEMBER}));

But even _THIS_ is stupid.  All this initialization really should
move to caller.  We can provide a "dst_init()" helper for protocols
that don't want to bother optimizing this.
