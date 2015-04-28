From: Jaeden Amero <jaeden.amero@ni.com>
Subject: Re: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Tue, 28 Apr 2015 15:36:54 -0500
Message-ID: <553FEF66.7010503@ni.com>
References: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com> <20150427.224713.291017556251723132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeff.westfahl@ni.com,
	mihai.neagu@ni.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150427.224713.291017556251723132.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2015 09:47 PM, David Miller wrote:
> From: Jaeden Amero <jaeden.amero@ni.com>
> Date: Mon, 27 Apr 2015 17:43:30 -0500
>
> A UDP checksum of zero, means "checksum not computed".  And your
> device isn't computing the checksum at all, but rather is leaving it
> at zero.

The "zero" checksum is not what gets sent over the wire. Independent of
the value of the checksum field, hardware generates a correct checksum
for payloads of 3 or more bytes. The bug is that hardware generates an
incorrect checksum for payloads of 2 or less bytes, unless the checksum
field is zeroed.

> You need to handle this properly by computing the checksum in
> software and then setting the TX descriptor bits such that the
> chip leaves the checksum field alone.

Unfortunately, the Cadence MACB doesn't support the enabling or
disabling of checksum generation per descriptor.
