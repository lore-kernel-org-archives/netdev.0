From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3  1/8] CAIF Protocol Stack
Date: Thu, 10 Dec 2009 12:11:41 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E0790311F064@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <4B1EE474.5000508@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <randy.dunlap@oracle.com>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:49731 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933999AbZLJLoA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 06:44:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B1EE474.5000508@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefano.

Thank you for good feedback.

stefano babic wrote:
>> +#define CAIF_PRIO_UNSPCEIFIED  0x0
> 
> The define is not used in code, but probably you would prefer to set
> CAIF_PRIO_UNSPECIFIED 

I'll remove this one.

> 
> 
>> diff --git a/include/linux/caif/caif_ioctl.h
>> b/include/linux/caif/caif_ioctl.h
>> +/*!\page  caif_ioctl.h
>> + * This file defines the management interface to CAIF.
>> + * It defines how CAIF channels are configured and become visible
>> in +the + * Linux file system, typically under "/dev".
> 
> This is not updated, you have already removed the char devices.
Right - agree. I'll remove this.
> 
>> + *
>> + *\b Example - creating a new AT character device: + * \code
>> +   fd = open("/dev/caifconfig",..);
>> +   struct caif_channel_create_action at_config = { +	 .name =
>> "cnhl2", +	 .config = {
>> +	    .channel = CAIF_CHTY_AT,
>> +	    .phy_ref = CAIF_PHY_LOW_LAT,
>> +	    .priority = CAIF_PRIO_HIGH
>> +	 }};
>> +   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
>> +   close(fd);
>> + * \endcode
>> + * This will cause a new AT channel to be available in at
>> "/dev/chnl2". + * This CAIF channel can then be connected by using
>> \ref open. + */
> 
> This is obsolete,too.

Yes, Thanks.

> 
>> +/* Specifies the type of device to create: NET device or CHAR
>> +device*/ enum caif_dev_type {
>> +	CAIF_DEV_CHR = 1,
>> +	CAIF_DEV_NET = 2
>> +};
> 
> You can remove this enum, it is not used anymore in your code.

Yes, I'll do it.

> 
>> +
>> +/** Used for identifying devices, PHY interfaces, etc.*/ struct
>> +caif_device_name { +	char name[DEVICE_NAME_LEN];	/*!< Device name */
>> +	enum caif_dev_type devtype;	/*!< Device type */
>> +};
> 
> I think this one is obsolete, too.

Yes, this is obsolete.

> 
>> +/* TODO: Move these defs to /usr/include/linux/socket.h */
>> +#define AF_CAIF    37 		/* CAIF Socket Address Family */
>> +#define PF_CAIF    37           /* CAIF Socket Protocol Family */
>> +#define SOL_CAIF   278		/* CAIF Socket Option Level */
> 
> You sent already a patch for socket.h, I think you can safely remove
> these duplicates. 
Yes they should be moved to include/linux/socket.h.
> 
>> +
>> +#define CAIF_DEFAULT_PRI       0xf
> 
> You have already defined CAIF_PRIO_NORMAL with the same value. Do you
> need both ? 
Hmm good question. My initial thinking was to have two self-contained
header files:caif_socket.h and caif_config.h. The first is used for
sockets and the second for modules using the kernel API (caif_kernel.h).
Perhaps I should look into the option of letting caif_config.h include
caif_socket.h allowing removal of duplicate types.

> 
>> +enum caif_link_selector {
>> +	CAIF_LINK_UNSPECIFIED	= 0x00,
>> +	CAIF_LINK_LOW_LATENCY	= 0xd0,
>> +	CAIF_LINK_HIGH_BANDW	= 0xe0
> 
> caif_phy_preference and caif_link_selector have the same values for
> priority. Should we have a single enum for both ? 
I'll remove the assignment to 0xd0 and 0xe0.
Link selection and priority are two fundamental different things.
Link Selectors are used to select the physical link such as SPI or UART,
while priority is about the channel's priority used for CAIF-packet
scheduling in the modem.

BR/Sjur

