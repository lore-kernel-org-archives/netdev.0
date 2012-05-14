From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Mon, 14 May 2012 09:54:46 -0700
Message-ID: <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
References: <20120513155206.GA26847@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120513155206.GA26847@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 May 2012 18:52:06 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> +		/* Userspace may produce vectors with count greater than
> +		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
> +		 * to let the rest of data to be fit in the frags.
> +		 */
Rather than complex partial code, just go through slow path for
requests with too many frags (or for really small requests).
Creating mixed skb's seems too easy to get wrong.
