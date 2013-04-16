From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 19:34:52 +0000
Message-ID: <57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
 <20130416.151141.1928940532005718606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20130416.151141.1928940532005718606.davem@davemloft.net>
Content-Language: en-US
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

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, April 16, 2013 3:12 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-kernel@vger.kernel.org; devel@linuxdriverproject.org
> Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
>
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 16 Apr 2013 12:03:51 -0700
>
> > Fixed: warning: cast from pointer to integer of different size
> > 
> > Reported-by: kbuild test robot <fengguang.wu@intel.com>
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>
> If you're coding pointers into request IDs you better make that explicit and add lots of comments explaining 
> why that's OK and why it's going to work  fine in these circumstances.

> I'm not applying this patch, it just makes a bad situation even worse.  Either your request IDs are 64-bit or they are not, it can't be both.

The Hyper-V hosts always use 64 bit request id. The guests can have 32 or 64 bit pointers which equal to
the ulong type size. So we cast it to ulong type. And, assigning 32bit integer to 64 bit variable works fine.

Actually, before the recent patch (f1ea3cd7011), the packet pointer was casted to ulong. And this patch
restore the same type casting as the old code.

The VMBus returns the same id in the completion packet. But the value has no effect on the host side.

Does these comments sound good?

Thanks,
- Haiyang
