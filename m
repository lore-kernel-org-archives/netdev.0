From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v2 01/22] fjes: Introduce FUJITSU Extended Socket
 Network Device driver
Date: Thu, 25 Jun 2015 00:32:40 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A542440A2@G01JPEXMBYT01>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1435114554-7151-2-git-send-email-izumi.taku@jp.fujitsu.com>
 <1435128637.2504.51.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"dvhart@infradead.org" <dvhart@infradead.org>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1435128637.2504.51.camel@perches.com>
Content-Language: ja-JP
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Thanks for your help.

> -----Original Message-----
> From: platform-driver-x86-owner@vger.kernel.org [mailto:platform-driver-x86-owner@vger.kernel.org] On Behalf Of Joe
> Perches
> Sent: Wednesday, June 24, 2015 3:51 PM
> To: Izumi, Taku/泉 拓
> Cc: netdev@vger.kernel.org; davem@davemloft.net; platform-driver-x86@vger.kernel.org; dvhart@infradead.org;
> rkhan@redhat.com; alexander.h.duyck@redhat.com; linux-acpi@vger.kernel.org; sergei.shtylyov@cogentembedded.com;
> stephen@networkplumber.org; yasu.isimatu@gmail.com
> Subject: Re: [PATCH v2 01/22] fjes: Introduce FUJITSU Extended Socket Network Device driver
> 
> On Wed, 2015-06-24 at 11:55 +0900, Taku Izumi wrote:
> > This patch adds the basic code of FUJITSU Extended Socket
> > Network Device driver.
> 
> trivial notes:
> 
> > diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
> []
> > +static int fjes_acpi_add(struct acpi_device *device)
> > +{
> []
> > +	result =
> > +	utf16s_to_utf8s((wchar_t *)str->string.pointer,
> > +			str->string.length, UTF16_LITTLE_ENDIAN,
> > +			str_buf, sizeof(str_buf) - 1);
> 
> I dislike this style as it's not normally used in the kernel.
> Most would use another tab indent on the utf16s_to_utf8s line
> if the line didn't fit, but this would is more common:

 To tell the truth, I dislike this style too.... OK, I'll fix.
 I reformatted to fix " CHECK: Alignment should match open parenthesis" 
 style issue.
 I thought the following style is easy to exceed 80 columns, I opted
 the above style.


> 	result = utf16s_to_utf8s((wchar_t *)str->string.pointer,
> 				 str->string.length, UTF16_LITTLE_ENDIAN,
> 				 str_buf, sizeof(str_buf) - 1);
> >
> > +	/* create platform_device */
> > +	plat_dev =
> > +	platform_device_register_simple(DRV_NAME, 0, fjes_resource,
> > +					ARRAY_SIZE(fjes_resource));
> 
> 	plat_dev = platform_device_register_simple(DRV_NAME, 0, fjes_resource,
> 						   ARRAY_SIZE(fjes_resource));
> 
> etc...
> 
> > +static acpi_status
> > +fjes_get_acpi_resource(struct acpi_resource *acpi_res, void *data)
> > +{
> > +	struct resource *res = data;
> > +	struct acpi_resource_address32 *addr;
> > +	struct acpi_resource_irq *irq;
> > +
> > +	switch (acpi_res->type) {
> > +	case ACPI_RESOURCE_TYPE_ADDRESS32:
> > +		addr = &acpi_res->data.address32;
> > +		res[0].start = addr->address.minimum;
> > +		res[0].end = addr->address.minimum +
> > +			addr->address.address_length - 1;
> > +		break;
> > +
> > +	case ACPI_RESOURCE_TYPE_IRQ:
> > +		irq = &acpi_res->data.irq;
> > +		if (irq->interrupt_count != 1)
> > +			return AE_ERROR;
> > +		res[1].start = irq->interrupts[0];
> > +		res[1].end = irq->interrupts[0];
> > +		break;
> > +
> > +	default:
> > +		break;
> > +	}
> > +
> > +	return AE_OK;
> > +}
> 
> Is this function used in this compilation?
> If not, it's odd to add code that isn't used.
> 
> Is it better to make the 2nd argument a
> struct resource * rather than a void * ?

  This function is used as a callback function of "acpi_walk_resources".
  Its signature is

   acpi_status(*acpi_walk_resource_callback) (struct acpi_resource * resource, void *context);

  Sincerely,
  Taku Izumi

> 
> --
> To unsubscribe from this list: send the line "unsubscribe platform-driver-x86" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
