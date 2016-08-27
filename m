From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Sat, 27 Aug 2016 17:30:42 +0200
Message-ID: <87vaymdyal.fsf@belgarion.home>
References: <20160825144314.1850730-1-arnd@arndb.de>
 <3062310.z9h3CgCZ7p@wuerfel> <87inuopw04.fsf@belgarion.home>
 <20160825223743.GK1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Yoshinori Sato <ysato@users.sourceforge.jp>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

Russell King - ARM Linux <linux@armlinux.org.uk> writes:

> On Thu, Aug 25, 2016 at 08:02:35PM +0200, Robert Jarzmik wrote:
>> Arnd Bergmann <arnd@arndb.de> writes:
>> 
>> > On Thursday, August 25, 2016 4:43:04 PM CEST Arnd Bergmann wrote:
>> >>  drivers/net/ethernet/smsc/smc91x.h | 50 +++++++++++++++++++++++---------------
>> >>  1 file changed, 30 insertions(+), 20 deletions(-)
>> >> 
>> >> While this patch fixes one bug on Neponset, it probably doesn't address
>> >> the one that Russell ran into first, so this is for review only for now,
>> >> until the remaining problem(s) have been worked out.
>> >> 
>> >
>> > The comment should have been on another patch, my mistake. please
>> > see v2.
>> >
>> > 	Arnd
>> 
>> Hi Arnd,
>> 
>> I didn't review the patch thoroughly, but I launched your 2 patches in my pxa
>> little farm.
>> 
>> The result is that lubbock and mainstone are all right, but zylonite is broken
>> (ie. networkless). I removed then these 2 patches and zylonite worked again.
>> 
>> I have also an error message on the console on a "broken" zylonite :
>>   Changing smcs91x MAC address to 08:00:3e:26:0a:5b: ifconfig: SIOCSIFHWADDR:
>>   Device or resource busy
>> 
>> I reran the test twice (2 times with your patches, 2 times without), the result
>> looks consistent, ie. zylonite doesn't really like them.
>
> Please try the patch below.  I sent this to Will a few days ago, as
> he said (on irc) that he was also seeing problems on a platform he
> had, but I've yet to hear back.  I've not posted it yet because I
> haven't got around to writing a commit description for it.
>
> It does require that at least one of 8-bit or 16-bit accesses are
> supported, but I think that's already true.

Hi Russell,

With your patch :
 - lubbock, mainstone and zylonite boards are working correctly
   => ie. all my boards are working correctly

 - the message "ifconfig: SIOCSIFHWADDR: Device or resource busy" is still there
   => this message is here even without your patch, so it's rather not relevant
   => this message is triggered by an "/sbin/ifconfig eth0 hw ether
   08:00:3e:26:0a:5b" command

So from a PXA testing point of view it's all good, ie.
Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>

Cheers.

-- 
Robert
