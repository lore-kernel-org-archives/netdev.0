From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 13 Apr 2016 22:30:27 -0400 (EDT)
Message-ID: <20160413.223027.844777521863481943.davem@davemloft.net>
References: <1460079411-31982-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460079411-31982-1-git-send-email-decui@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Thu,  7 Apr 2016 18:36:51 -0700

> +struct vmpipe_proto_header {
> +	u32 pkt_type;
> +	u32 data_size;
> +} __packed;

There is no reason to specify __packed here.

The types are strongly sized to word aligned quantities.
No holes are possible in this structure, nor is any padding
possible either.

Do not ever slap __packed onto protocol or HW defined structures,
simply just define them properly with proper types and explicit
padding when necessary.
> +	struct {
> +		struct vmpipe_proto_header hdr;
> +		char buf[HVSOCK_SND_BUF_SZ];
> +	} __packed send;

And so on, and so forth..

I'm really disappointed that I couldn't even get one hunk into this
patch submission without finding a major problem.

I expect this patch to take several more iterations before I can even
come close to applying it.  So please set your expectations properly,
and also it seems like nobody else wants to even review this stuff
either.  It is you who needs to find a way to change all of this, not
me.
