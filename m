From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next 00/27] Remove VLAN CFI bit abuse
Date: Wed, 14 Dec 2016 03:00:18 +0100
Message-ID: <20161214020017.c6u3l4dttkojscq2@rere.qmqm.pl>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
 <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
 <20161213171626.76e7dced@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:40932 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753256AbcLNCAX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 21:00:23 -0500
Content-Disposition: inline
In-Reply-To: <20161213171626.76e7dced@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 05:16:26PM -0800, Stephen Hemminger wrote:
> On Tue, 13 Dec 2016 01:12:32 +0100 (CET)
> Micha³ Miros³aw <mirq-linux@rere.qmqm.pl> wrote:
> > This series removes an abuse of VLAN CFI bit in Linux networking stack.
> > Currently Linux always clears the bit on outgoing traffic and presents
> > it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).
> > 
> > This uses a new vlan_present bit in struct skbuff, and removes an assumption
> > that vlan_proto != 0 when VLAN tag is present.
> > 
> > As I can't test most of the driver changes, please look at them carefully.
> > 
> > The series is supposed to be bisect-friendly and that requires temporary
> > insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> > JIT changes per architecture.
> 
> I wonder if CFI can every validly be non-zero in the modern world, on Hyper-V.
> There are no token ring devices and that seems to be the only use case where CFI would
> be non-zero. Unless someone is planning to reuse it a a protocol bit which seems
> like a really bad idea.
> 
> Maybe the right thing is to keep hard coded as zero and not start adding
> more untestable code conditions.
> 
> My recommendation would be get rid of VLAN_TAG_PRESENT, but don't preserve
> CFI bit.

According to Wikipedia page [1] on 802.1Q, CFI bit got already changed
to DEI (Drop eligible indicator) in 2011 revision of the IEEE standard.

I can't verify this, though.

Best Regards,
Micha³ Miros³aw

[1] https://en.wikipedia.org/wiki/IEEE_802.1Q#Frame_format
