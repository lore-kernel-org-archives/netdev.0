From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: no md5sig option size check bug
Date: Sat, 07 Aug 2010 20:24:16 -0700 (PDT)
Message-ID: <20100807.202416.124037373.davem@davemloft.net>
References: <AANLkTimHMAwi158ycRh_nRYPYUTSkww-psdFai-LsTsb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, gilad@codefidence.com,
	yony@comsleep.com, ori@comsleep.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dp@highloadlab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimHMAwi158ycRh_nRYPYUTSkww-psdFai-LsTsb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <dp@highloadlab.com>
Date: Sat, 7 Aug 2010 23:17:52 +0400

> From: Dmitry Popov <dp@highloadlab.com>
> 
> tcp_parse_md5sig_option doesn't check md5sig option (TCPOPT_MD5SIG)
> length, but tcp_v[46]_inbound_md5_hash assume that it's at least 16
> bytes long.
> 
> Signed-off-by: Dmitry Popov <dp@highloadlab.com>

I'll apply this, but the memcmp() we do against this pointer is always
safe because there's at least skb_shared_info()'s worth of valid
memory past skb->data guarenteed at all times which is much larger
than 16 bytes.

So at worst we'd access garbage, but never past a valid piece of
allocated memory.

Thanks.
