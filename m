From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V6 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Thu, 26 May 2011 23:28:36 +0300
Message-ID: <20110526202836.GA1951@redhat.com>
References: <1306440020.5180.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306440020.5180.47.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 26, 2011 at 01:00:20PM -0700, Shirley Ma wrote:
> 3. Add sleep in vhost shutting down instead of busy-wait for outstanding
>    DMAs.

I still think this is not much better. We need to use a
completion structure and wait on it instead.
If this gets blocked thinkably a tx watchdog can fire and save us
from blocking forver :)
