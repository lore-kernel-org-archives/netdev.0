From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Sat, 23 May 2009 08:29:25 +0200
Message-ID: <4A1797C5.1040907@grandegger.com>
References: <4A16BAAE.3070401@grandegger.com>
	<fa686aa40905220808kecd06cdqb570b78ca97f0ca6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree-discuss <devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>,
	linuxppc-dev <Linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <fa686aa40905220808kecd06cdqb570b78ca97f0ca6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Grant,

Grant Likely wrote:
> Hi Wolfgang, thanks for the quick response.  Comments below...
> 
> On Fri, May 22, 2009 at 8:46 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>> +++ net-next-2.6/Documentation/powerpc/dts-bindings/can/sja1000.txt
>> @@ -0,0 +1,37 @@
>> +Memory mapped SJA1000 CAN controller from NXP (formerly Philips)
>> +
>> +Required properties:
>> +
>> +- compatible : should be "nxp,sja1000".
>> +- reg : should specify the chip select, address offset and size used
>> +       for the chip depending on the bus it is connected to.
>> +- interrupts: property with a value describing the interrupt source
>> +       (number and sensitivity) for that device. The encoding depends
>> +       on the type of interrupt controller used.
> 
> Hmmm, "reg", "interrupts", and "interrupt-parent" are well understood
> properties.  I don't think we need to keep boilerplate defining the
> meaning every time a new binding is added.  (general musing; not an
> ack or nack of this patch)

OK.

> However, what should be defined is *what* the register range is (ie.
> one tuple; location of device registers), and what the interrupts are
> (ie. single tuple for device's irq line).  Granted this is a trivial
> case, but in the case of devices with more than one address range or
> irq line, the meaning of each tuple is critical information.  I think
> it would be a good pattern to establish.

Sounds reasonable.

>> +Optional properties:
>> +
>> +- interrupt-parent : the phandle for the interrupt controller that
>> +       services interrupts for that device.
> 
> Thinking further; I wouldn't even mention "interrupt-parent" here.
> Anyone working with this stuff must already understand irq routing.

OK, I will remove it.

>> +- clock-frequency : CAN system clock frequency in Hz, which is normally
>> +       half of the oscillator clock frequency. If not specified, a
>> +       default value of 8000000 (8 MHz) is used.
> 
> A clock-frequency property typically refers to the bus clock
> frequency.  Something like can-frequency would be better.

Ah, right, but I'm also not happy with "can-frequency". The manual
speaks about the "internal clock", which is half of the external
oscillator frequency. Maybe "internal-clock-frequency" might be better.

>> +- cdr-reg : value of the SJA1000 clock divider register according to
>> +       the SJA1000 data sheet. If not specified, a default value of
>> +       0x48 is used.
> 
> Ewh.  The driver should be clueful enough to derive the clock divider
> value given both the bus and can frequencies.  I don't like this
> property.

The clock divider register controls the CLKOUT frequency for the
microcontroller another CAN controller and allows to deactivate the
CLKOUT pin. It's not used to configure the CAN bus frequency.

> 
>> +- ocr-reg : value of the SJA1000 output control register according to
>> +       the SJA1000 data sheet. If not specified, a default value of
>> +       0x0a is used.
> 
> Ditto here; the binding should describe the usage mode; not the
> register settings to get the usage mode.  What sort of settings will
> the .dts author be writing here?

Unfortunately, there are many:

clkout-frequency
bypass-comperator
tx1-output-on-rx-irq

#define OCR_MODE_BIPHASE  0x00
#define OCR_MODE_TEST     0x01
#define OCR_MODE_NORMAL   0x02
#define OCR_MODE_CLOCK    0x03

#define OCR_TX0_INVERT    0x04
#define OCR_TX0_PULLDOWN  0x08
#define OCR_TX0_PULLUP    0x10
#define OCR_TX0_PUSHPULL  0x18
#define OCR_TX1_INVERT    0x20
#define OCR_TX1_PULLDOWN  0x40
#define OCR_TX1_PULLUP    0x80
#define OCR_TX1_PUSHPULL  0xc0

I think implementing properties for each option is overkill.

Wolfgang.

> 
