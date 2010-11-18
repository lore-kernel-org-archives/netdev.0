From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] of/phylib: Use device tree properties to initialize
	Marvell PHYs.
Date: Wed, 17 Nov 2010 16:01:19 -0800
Message-ID: <4CE46CCF.4080707@caviumnetworks.com>
References: <1290038071-13296-1-git-send-email-ddaney@caviumnetworks.com>
	<1290038071-13296-2-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>,
	Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
To: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1290038071-13296-2-git-send-email-ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/17/2010 03:54 PM, David Daney wrote:
> Some aspects of PHY initialization are board dependent, things like
> indicator LED connections and some clocking modes cannot be determined
> by probing.  The dev_flags element of struct phy_device can be used to
> control these things if an appropriate value can be passed from the
> Ethernet driver.  We run into problems however if the PHY connections
> are specified by the device tree.  There is no way for the Ethernet
> driver to know what flags it should pass.
>
> If we are using the device tree, the struct phy_device will be
> populated with the device tree node corresponding to the PHY, and we
> can extract extra configuration information from there.
>
> The next question is what should the format of that information be?
> It is highly device specific, and the device tree representation
> should not be tied to any arbitrary kernel defined constants.  A
> straight forward representation is just to specify the exact bits that
> should be set using the "marvell,reg-init" property:
>
>        phy5: ethernet-phy@5 {
> 	reg =<5>;
> 	device_type = "ethernet-phy";
> 	marvell,reg-init =
> 		<0x00030010 0x5777>, /* Reg 3,16<- 0x5777 */
> 		<0x00030011 0x00aa>, /* Reg 3,17<- 0x00aa */
> 		<0x00030012 0x4105>, /* Reg 3,18<- 0x4105 */
> 		<0x00030013 0x0060>; /* Reg 3,19<- 0x0060 */
> 		<0x00020015 0x00300000>; /* clear bits 4..5 of Reg 2,21 */

Well, of course these mask bits are reversed.  That last line should 
really be:

  	<0x00020015 0xffcf0000>; /* clear bits 4..5 of Reg 2,21 */


>        };
>
> The Marvell PHYs have a page select register at register 22 (0x16), we
> can specify any register by its page and register number.  These are
> encoded in the high and low parts of the first word.  The second word
> contains a mask and value to be ORed in its high and low parts.
> property, the PHY initialization is unchanged.
[...]

David Daney
