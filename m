From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] tcp: md5: extend the tcp_md5sig struct to
 specify a key address prefix
Date: Sat, 10 Jun 2017 18:58:11 -0400 (EDT)
Message-ID: <20170610.185811.1771245027556677313.davem@davemloft.net>
References: <20170607005414.25361-1-colona@arista.com>
        <20170610021449.16091-1-colona@arista.com>
        <20170610021449.16091-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colona@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170610021449.16091-2-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Delalande <colona@arista.com>
Date: Fri,  9 Jun 2017 19:14:49 -0700

> Add a flag field and address prefix length at the end of the tcp_md5sig
> structure so users can configure an address prefix length along with a
> key. Make sure shorter option values are still accepted in
> tcp_v4_parse_md5_keys and tcp_v6_parse_md5_keys to maintain backward
> compatibility.
> 
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Signed-off-by: Eric Mowat <mowat@arista.com>
> Signed-off-by: Ivan Delalande <colona@arista.com>

As I believe was previously stated, the problem with this approach is
that if a new tool requests the prefix length and is run on an older
kernel, the kernel will return success even though the prefix length
was not taken into account.

We do not want to get a success back when the operation requested was
not performed.
