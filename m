From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH: kmalloc packet slab
Date: Mon, 27 Dec 2004 18:17:32 +0100
Message-ID: <41D043AC.2070203@trash.net>
References: <1104156983.20944.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maillist netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261932AbUL0RSq@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1104156983.20944.25.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> The networking world runs in 1514 byte packets pretty much all the time.
> This adds a 1620 byte slab for such objects and is one of the internally
> generated Red Hat patches we use on things like Fedora Core 3. Original:
> Arjan van de Ven.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>

Why 1620 bytes ? Most drivers allocate packet_size + 2 bytes.
dev_alloc_skb adds another 16 bytes, finally alloc_skb adds
sizeof(struct skb_shared_info). So we get:

(32bit): 1514b + 2b + 16b + 160b = 1692b
(64bit): 1514b + 2b + 16b + 312b = 1844b

On paths using alloc_skb instead of dev_alloc_skb it's 16 bytes
less, but 1620 bytes is still too small for full-sized packets.

Regards
Patrick
