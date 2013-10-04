From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 0/3] net: mv643xx_eth: various small fixes for v3.12
Date: Fri, 04 Oct 2013 19:34:14 +0200
Message-ID: <524EFC16.80104@gmail.com>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20131004165354.GA9065@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20131004165354.GA9065@localhost>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 10/04/2013 06:53 PM, Ezequiel Garcia wrote:
> On Wed, Oct 02, 2013 at 12:57:19PM +0200, Sebastian Hesselbarth wrote:
>> This patch set comprises some one-liners to fix issues with repeated
>> loading and unloading of a modular mv643xx_eth driver.
>>
>> First two patches take care of the periodic port statistic timer, that
>> updates statistics by reading port registers using add_timer/mod_timer.
>>
>> Patch 1 moves timer re-schedule from mib_counters_update to the timer
>> callback. As mib_counters_update is also called from non-timer context,
>> this ensures the timer is reactivated from timer context only.
>>
>> Patch 2 moves initial timer schedule from _probe() time to right before
>> the port is actually started as the corresponding del_timer_sync is at
>> _stop() time. This fixes a regression, where unloading the driver from a
>> non-started eth device can cause the timer to access deallocated mem.
>>
>> Patch 3 adds an assignment of the ports device_node to the corresponding
>> self-created platform_device. This is required to allow fixups based on
>> the device_node's compatible string later. Actually, it is also a potential
>> regression because we already check compatible string for Kirkwood, but
>> does not (yet) rely on the fixup.
>>
>> All patches are based on v3.12-rc3 and have been tested on Kirkwood-based
>> Seagate Dockstar.
>>
>> Patches 1 and 2 can also possibly queued up for -stable.
>>
>> Sebastian Hesselbarth (3):
>>    net: mv643xx_eth: update statistics timer from timer context only
>>    net: mv643xx_eth: fix orphaned statistics timer crash
>>    net: mv643xx_eth: fix missing device_node for port devices
>>
>>   drivers/net/ethernet/marvell/mv643xx_eth.c |    7 +++----
>>   1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> ---
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
>> Cc: Jason Cooper <jason@lakedaemon.net>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>
> Sorry for missing this series, somehow my filters failed to catch it.
>
> Anyway, I would expect these patches to have my Reported-by, but I'm
> glad to see you've solved all the issues.

True, thanks to Ezequiel for initially reporting the issues. I will
have to be more careful about the Reported-by next time.

> I see David has already applied them all, but I'll re-run my tests to
> check there aren't any more issues if I can find some time next week.
>
> Thanks for taking care of it!
