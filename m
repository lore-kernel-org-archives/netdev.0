From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
Date: Thu, 11 Aug 2016 14:09:53 +0200
Message-ID: <87lh038q26.fsf@vitty.brq.redhat.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
 <CO2PR11MB008839DC3A61A4F211CC148F971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CO2PR11MB008839DC3A61A4F211CC148F971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
 (Yuval Mintz's message of "Thu, 11 Aug 2016 11:46:18 +0000")
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

Yuval Mintz <Yuval.Mintz@qlogic.com> writes:

>> +static void netvsc_inject_enable(struct net_device_context
>> +*net_device_ctx) {
>> +	net_device_ctx->vf_inject = true;
>> +}
>> +
>> +static void netvsc_inject_disable(struct net_device_context
>> +*net_device_ctx) {
>> +	net_device_ctx->vf_inject = false;
>> +
>> +	/* Wait for currently active users to drain out. */
>> +	while (atomic_read(&net_device_ctx->vf_use_cnt) != 0)
>> +		udelay(50);
>> +}
>
> That was already the behavior before, but are you certain you
> want to unconditionally block without any possible timeout?

Yes, this is OK. After PATCH4 of this series there is only one place
which takes the vf_use_cnt (netvsc_recv_callback()) and it is an
interrupt handler, there are no sleepable operations there.

-- 
  Vitaly
