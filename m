From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 8/9] net: filter: rework/optimize internal
 BPF interpreter's instruction set
Date: Thu, 27 Mar 2014 15:23:19 -0400 (EDT)
Message-ID: <20140327.152319.1469721259196062415.davem@davemloft.net>
References: <1395867970-1338-1-git-send-email-dborkman@redhat.com>
	<1395867970-1338-9-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, hagen@jauu.net,
	keescook@chromium.org, pmoore@redhat.com, mingo@kernel.org,
	hpa@linux.intel.com, linux-kernel@vger.kernel.org
To: dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395867970-1338-9-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 26 Mar 2014 22:06:09 +0100

>   - Adds swab insns for 32/64-bit

I don't like this.

You don't want a swab instruction, you want "endian X to endian Y".  Just
like we have "cpu_to_le32()", "le32_to_cpu()" et al. in the kernel.

That way the user can be completely oblivious as to the endianness of
the cpu it's running on.

So if you ask for a "to little endian" swab, if the chip is
little-endian then no code needs to be emitted at all, it's a nop.

There is zero reason for the BPF program emitted by userspace to be
dependant upon the cpu endianness.
