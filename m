From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/1] net: lls select poll support
Date: Sun, 23 Jun 2013 18:44:37 -0700 (PDT)
Message-ID: <20130623.184437.1772856342146874217.davem@davemloft.net>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, alexr@mellanox.com,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 19 Jun 2013 13:04:21 +0300

> One question: do we need in sock_poll() to test that sock->sk is not null?
> (Thanks to Willem de Bruijn for pointing this out.) 

We should not have to.

Please clean up various things in this patch:

1) You have cases where you add tons of unnecessary empty lines, of the
   form:

	if (foo) {
	/* EMPTY LINE */
		code...

    please get rid of them.

2) Some of the LL loops have conditions that are not properly formatted,
   I see things like:

	do {
		...
	} while (x && y && z
			&& whatever)

   That "&& whatever" is not properly indented.  You must always indent
   multi-line conditions like this:

	xxx (x && y &&
	     z && ...)

   That is, operators always end the line, the never begin the line.
   And one the second and subsequent lines you must line up the first
   character with the first column after the openning parenthesis of
   the first line.  You should not just use a series of only TAB
   characters to indent these expressions.

Thanks.
