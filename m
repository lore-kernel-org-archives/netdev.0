From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 7/7] Drivers: hv: vmbus: disable local interrupt
 when hvsock's callback is running
Date: Wed, 29 Jul 2015 15:28:09 -0700 (PDT)
Message-ID: <20150729.152809.1531386671239230150.davem@davemloft.net>
References: <1438086930-19483-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 stephen@networkplumber.org, stefanha@redhat.com, netdev@vger.kernel.org,
 apw@canonical.com, pebolle@tiscali.nl, dan.carpenter@oracle.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1438086930-19483-1-git-send-email-decui@microsoft.com>
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
Date: Tue, 28 Jul 2015 05:35:30 -0700

> In the SMP guest case, when the per-channel callback hvsock_events() is
> running on virtual CPU A, if the guest tries to close the connection on
> virtual CPU B: we invoke vmbus_close() -> vmbus_close_internal(),
> then we can have trouble: on B, vmbus_close_internal() will send IPI
> reset_channel_cb() to A, trying to set channel->onchannel_callbackto NULL;
> on A, if the IPI handler happens between
> "if (channel->onchannel_callback != NULL)" and invoking
> channel->onchannel_callback, we'll invoke a function pointer of NULL.
> 
> This is why the patch is necessary.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

Sorry, I do not accept that you must use conditional locking and/or
IRQ disabling.

Boil it down to what is necessary for the least common denominator,
and use that unconditionally.
