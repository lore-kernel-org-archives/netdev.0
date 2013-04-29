From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Fix a compiler warning in netvsc_send()
Date: Mon, 29 Apr 2013 14:09:32 -0400 (EDT)
Message-ID: <20130429.140932.1477434738582260564.davem@davemloft.net>
References: <1367000755-2571-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1367000755-2571-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri, 26 Apr 2013 11:25:55 -0700

> Fixed: warning: cast from pointer to integer of different size
> 
> The Hyper-V hosts always use 64 bit request id. The guests can have 32 or 64
> bit pointers which equal to the ulong type size. So we cast it to ulong type.
> And, assigning 32bit integer to 64 bit variable works fine.
> 
> The VMBus returns the same id in the completion packet. But the value has no
> effect on the host side.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, but:

> -		req_id = (u64)packet;
> +		req_id = (ulong)packet;

I really do not like these shorthands for fundamental C types, we
generally do not use "ulong", "uint" etc.  Please expand them out
explicitly to "unsigned long", "unsigned int", etc.
