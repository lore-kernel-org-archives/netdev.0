From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Mon, 27 Apr 2015 22:47:13 -0400 (EDT)
Message-ID: <20150427.224713.291017556251723132.davem@davemloft.net>
References: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeff.westfahl@ni.com,
	mihai.neagu@ni.com
To: jaeden.amero@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaeden Amero <jaeden.amero@ni.com>
Date: Mon, 27 Apr 2015 17:43:30 -0500

> If we set the checksum field in the UDP header to 0, the checksum is
> computed correctly.

I think this is completely bogus.

A UDP checksum of zero, means "checksum not computed".  And your
device isn't computing the checksum at all, but rather is leaving it
at zero.

You need to handle this properly by computing the checksum in
software and then setting the TX descriptor bits such that the
chip leaves the checksum field alone.
