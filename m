From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3  3/8] CAIF Protocol Stack
Date: Wed, 16 Dec 2009 17:15:12 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079031549D1@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <4B27B284.5010009@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <randy.dunlap@oracle.com>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: "stefano babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:43894 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934938AbZLPQS2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 11:18:28 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B27B284.5010009@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefano babic wrote:
> sjur.brandeland@stericsson.com wrote:
>> diff --git a/include/net/caif/caif_chr.h
>> b/include/net/caif/caif_chr.h 
>> new file mode 100644 index 0000000..ebd89f8
>> --- /dev/null
>> +++ b/include/net/caif/caif_chr.h
> 
> Only a question of taste, but there is no chr device anymore, maybe
> another name for the file should be more appropriate.

Yes, I'll rename to caif_dev.h

>> +struct caif_service_config;
>> +enum cf_chr_dev_type {
...
>> +extern int serial_use_stx;
>> +extern int (*netdev_mgmt_func) (int action, union caif_action
>> *param); +int caifdev_phy_reg(struct layer *phyif, struct
>> cfcnfg_phy_mgmt *mgmt); +int caifdev_phy_instanciate(struct
>> cfcnfg_phy_config *phy_config); +int caifdev_phy_register(struct
>> layer *phyif, +			 enum cfcnfg_phy_type phy_type,
>> +			 enum cfcnfg_phy_preference phy_pref);
>> +int caifdev_phy_unregister(struct layer *phyif);
>> +int caifdev_phy_loop_register(struct layer *phyif,
>> +			      enum cfcnfg_phy_type phy_type);
>> +int caifdev_phy_spi_xmitlen(struct cfspil *layr);
>> +struct cfpkt *caifdev_phy_spi_getxmitpkt(struct cfspil *layr);
> 
> All these functions seem obsolete.
> 
>> +int caif_register_chrdev(int (*chrdev_mgmt)
>> +			(int action, union caif_action *param));
>> +void caif_unregister_chrdev(void);
> 
> Obsolete, too.

Yes, I agree. This header file needs some serious cleanup.
I'll rename it to caif_dev.h add config_util and strip it down 
to something like this:
[snip]
struct caif_service_config;
int caifdev_adapt_register(struct caif_channel_config *config,
			   struct layer *adap_layer);
int caifdev_adapt_unregister(struct layer *adap_layer);
struct cfcnfg *get_caif_conf(void);
void caif_register_ioctl(int (*ioctl)(unsigned int cmd,
				      unsigned long arg,
				      bool));
int caif_ioctl(unsigned int cmd, unsigned long arg, bool from_use_land);
void caif_unregister_netdev(void);
int channel_config_2_link_param(struct cfcnfg *cnfg,
				struct caif_channel_config *s,
				struct cfctrl_link_param *l);


>> diff --git a/include/net/caif/caif_config_util.h
... 
> Do we need an extra-header only to set the prototype of a single
> function ? Probably can we move it into another header file.

You're right, I'll move this into caif_dev.h (see above). 

BR/Sjur
