From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.6 SCTP updates
Date: Fri, 13 Feb 2004 21:52:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213215227.270a8147.davem@redhat.com>
References: <Pine.LNX.4.58.0402131443350.2190@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402131443350.2190@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Feb 2004 16:07:05 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Please do a
> 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
> to get the following fixes to SCTP on top of linux 2.6.2.

I am pulling this, however I strongly disagree with this change:

> # 04/02/12      sri@us.ibm.com  1.1552
> # [SCTP] Use __get_free_pages() to allocate ssnmap.
> #
> # This is needed to avoid kmalloc()'s 128K limit when an association is
> # initialized with a large no. of streams(more than 65000 inbound +
> # outbound streams).

This is madness because it means that every assosciation created eats
at least PAGE_SIZE bytes of memory, even if the ssnmap is tiny.

Maybe you should just brance between two allocation schemes based upon
what sctp_ssnmap_size() returns.
