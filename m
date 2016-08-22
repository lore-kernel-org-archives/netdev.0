From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: avoid packet loss when
 ethernet header crosses page boundary
Date: Mon, 22 Aug 2016 17:55:23 +0100
Message-ID: <57BB2E7B.5040303@citrix.com>
References: <1471880577-21380-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Juergen Gross <jgross@suse.com>,
        Patrick Talbert <ptalbert@redhat.com>,
        <linux-kernel@vger.kernel.org>,
        David Vrabel <david.vrabel@citrix.com>,
        <xen-devel@lists.xenproject.org>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471880577-21380-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/08/16 16:42, Vitaly Kuznetsov wrote:
> 
> I see two ways to fix the issue:
> - Change the 'wire' protocol between netfront and netback to start keeping
>   the original SKB structure. We'll have to add a flag indicating the fact
>   that the particular request is a part of the original linear part and not
>   a frag. We'll need to know the length of the linear part to pre-allocate
>   memory.

I don't think there needs to be a protocol change.  I think the check in
netback is bogus -- it's the total packet length that must be >
HLEN_ETH.  The upper layers will pull any headers from the frags as
needed (or if necessary, netback could pull a minimum amount).

There's no need to preserve the skb layout (e.g., look how the to-guest
direction we do not do this).

David
