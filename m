From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next RFC 3/5] xen-netback: Remove
 old TX grant copy definitons
Date: Wed, 30 Oct 2013 09:39:53 +0000
Message-ID: <5270E1F902000078000FDFCA@nat28.tlf.novell.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
 <1383094220-14775-4-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <jonathan.davies@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Zoltan Kiss" <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-4-git-send-email-zoltan.kiss@citrix.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 30.10.13 at 01:50, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> These became obsolate with grant mapping.

I didn't look at this in detail, but I'm surprised you can get away
without any copying: For one, the header part needs copying
anyway, so you'd pointlessly map and then copy it if it's small
enough. And second you need to be prepared for the frontend
to hand you more slots than you can fit in MAX_SKB_FRAGS
(namely when MAX_SKB_FRAGS < XEN_NETIF_NR_SLOTS_MIN),
which you can't handle with mapping alone afaict.

Jan
