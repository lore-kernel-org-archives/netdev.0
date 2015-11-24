From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head
 room in the skb
Date: Tue, 24 Nov 2015 09:55:32 +0100
Message-ID: <20151124085532.GA1740@breakpoint.cc>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-8-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448321346-21357-8-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

K. Y. Srinivasan <kys@microsoft.com> wrote:
> The rndis header is 116 bytes big and can be placed in the default
> head room that will be available in the skb. Since the netvsc packet
> is less than 48 bytes, we can use the skb control buffer
> for the netvsc packet. With these changes we don't need to
> ask for additional head room.

Minor nit: could you add a BUILD_BUG_ON test for this?  Something like

BUILD_BUG_ON(sizeof(struct hv_netvsc_packet) > FIELD_SIZEOF(struct sk_buff, cb));
