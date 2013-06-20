From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/x25: fix address parsing bug in
 x25_parse_address_block.
Date: Wed, 19 Jun 2013 17:59:28 -0700 (PDT)
Message-ID: <20130619.175928.1277008545805789566.davem@davemloft.net>
References: <1371673956-471-1-git-send-email-steve.moorby@ntlworld.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, akpm@linux-foundation.org,
	paulmck@linux.vnet.ibm.com, jiri@resnulli.us,
	linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steve.moorby@ntlworld.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371673956-471-1-git-send-email-steve.moorby@ntlworld.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Moorby <steve.moorby@ntlworld.com>
Date: Wed, 19 Jun 2013 21:32:36 +0100

> This problem was discovered when a linux box was incorrectly rejecting
> calls from some X.25 equipment.  The problem was diagnosed to an incorrect
> address length calculation in 'x25_parse_address_block', the calculation
> did not account for the address digits being BCD encoded.  The correct
> calculation is already performed on line 155.
> 
> Patched on linux-next 18-Jun-2013
> Tested on 2.6.32-45-generic
> 
> Signed-off-by: Stephen Moorby <steve.moorby@ntlworld.com>

This change has two problems:

1) If there is existing code that does the calculation correctly, don't
   get creative and express the calculation differently than the existing
   code.

2) If there are two places doing the same thing, write a helper function
   that does it in one place.

The exact reason this bug exists is because of code duplication, you are
making it even worse by writing the same calculation two different ways.

Please fix this up and resubmit, thanks.
