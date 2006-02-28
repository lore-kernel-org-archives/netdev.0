From: "Paul Rolland" <rol@witbe.net>
Subject: Re: [2.4.32 - 2.6.15.4] e1000 - Fix mii interface
Date: Tue, 28 Feb 2006 11:46:31 +0100
Message-ID: <001101c63c54$3d02f040$b600a8c0@cortex>
References: <Pine.WNT.4.63.0602271818570.284@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <john.ronciak@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932166AbWB1KqI@vger.kernel.org>
To: "'Jesse Brandeburg'" <jesse.brandeburg@intel.com>,
	<linux-kernel@vger.kernel.org>
In-reply-to: <Pine.WNT.4.63.0602271818570.284@jbrandeb-desk.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jesse,

>   					spddplx += (mii_reg & 0x100)
> -						   ? FULL_DUPLEX :
> -						   HALF_DUPLEX;
> +						   ? DUPLEX_FULL :
> +						   DUPLEX_HALF;

As I said in my first mail, I didn't want to go that way as one of the
two DUPLEX_FULL or DUPLEX_HALF is defined as being 0, which prevents
detecting incorrect/incomplete initializations.

The problem I had came from :
mii-tool -F 100BaseTx-FD eth0
when at the same time the ethtool interface was OK.

But you are right, the change I made missed the second caller.

The correct change is yours, though for the reason I put above, I think
it'll make it harder to spot other bugs ;)

Well done,
Paul
