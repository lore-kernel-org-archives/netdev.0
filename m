From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [RFC 4/4] [powerpc] Implement a p1010rdb clock source.
Date: Sat, 6 Aug 2011 15:59:47 -0500
Message-ID: <3C4B6145-5C75-4A3C-B504-DA32E0D2EC8A@kernel.crashing.org>
References: <1312603504-30282-1-git-send-email-holt@sgi.com>
	<1312603504-30282-5-git-send-email-holt@sgi.com>
	<4E3D4875.30707@pengutronix.de>
	<39414D86-7822-4B92-B005-351890A2A167@kernel.crashing.org>
	<20110806205010.GQ4926@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de,
	"linuxppc-dev@lists.ozlabs.org Development" <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20110806205010.GQ4926@sgi.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


On Aug 6, 2011, at 3:50 PM, Robin Holt wrote:

> On Sat, Aug 06, 2011 at 11:52:45AM -0500, Kumar Gala wrote:
>> 
>> On Aug 6, 2011, at 8:58 AM, Marc Kleine-Budde wrote:
>> 
>>> On 08/06/2011 06:05 AM, Robin Holt wrote:
>>>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>>>> to work.  This patch provides the minimum functionality.
>>> 
>>> This patch has to go via the powerpc git tree. Added
>>> linuxppc-dev@lists.ozlabs.org on CC.
>>> 
>>>> Signed-off-by: Robin Holt <holt@sgi.com>
>>>> To: Marc Kleine-Budde <mkl@pengutronix.de>
>>>> To: Wolfgang Grandegger <wg@grandegger.com>
>>>> To: U Bhaskar-B22300 <B22300@freescale.com>
>>>> Cc: socketcan-core@lists.berlios.de
>>>> Cc: netdev@vger.kernel.org
>>>> ---
>>>> arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++++++++++++++
>>>> 1 files changed, 78 insertions(+), 0 deletions(-)
>> 
>> NAK.
>> 
>> This doesn't look right at all.  We should be doing something based on the device tree node that isn't board specific.
>> 
>> I believe Bhaskar has a version of flexcan support that he's been working on cleanup up for upstream.
> 
> That version may be similar to what is in the freescale BSP which puts
> the clock functions inside flexcan.c
> 
> The powerpc arch already provides a means for individual boards to provide
> the clock functions.  I am not posting this patch here for acceptance
> for powerpc and I am sure I will get feedback there when I post to
> their mailing list.  I am posting it here only to show that the flexcan
> developers earlier assertion that this can and should be done in the arch
> tree is correct and will work for the p1010 assuming we can get changes
> into the arch/powerpc directory to implement these clk_* functions.

My point is that I don't think they should live in the arch code.  The clk_* functions you want to implement are tied more the FlexCAN IP than anything arch specific.  As such I believe they should be in the driver.

For example when FSL has a P9999 with FlexCAN on it, we should NOT have to add any arch code to support it.

- k
