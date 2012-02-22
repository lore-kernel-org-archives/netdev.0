From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v2 1/2] netdev: driver: ethernet: add cpsw address
 lookup engine support
Date: Wed, 22 Feb 2012 16:43:07 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293178EBB0@DBDE01.ent.ti.com>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
	 <1329763023-29580-2-git-send-email-mugunthanvnm@ti.com>
 <1329777452.8318.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43439 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab2BVQnR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 11:43:17 -0500
In-Reply-To: <1329777452.8318.5.camel@joe2Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, February 21, 2012 4:08 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH v2 1/2] netdev: driver: ethernet: add cpsw address
> lookup engine support
> 
> On Tue, 2012-02-21 at 00:07 +0530, Mugunthan V N wrote:
> > TI CPSW ethernet switch has a built-in address lookup engine.  This
> patch adds
> > the code necessary for programming this module.
> 
> just some style notes.
> 
> > diff --git a/drivers/net/ethernet/ti/cpsw_ale.c
> b/drivers/net/ethernet/ti/cpsw_ale.c
> []
> > +struct ale_control_info {
> > +	const char	*name;
> > +	int		offset, port_offset;
> > +	int		shift, port_shift;
> > +	int		bits;
> > +};
> > +
> > +#define CTRL_GLOBAL(name, bit)		{#name, ALE_CONTROL, 0, bit, 0,
> 1}
> > +#define CTRL_UNK(name, shift, bits)	{#name, ALE_UNKNOWNVLAN, 0,
> shift, \
> > +						0, bits}
> > +#define CTRL_PORTCTL(name, start, bits)	{#name, ALE_PORTCTL, 4,
> start, 0, bits}
> 
> named initializers might be more readable,
> embedding the index might be too.

Agreed, will used named initializers also with embedding the index.

> []
> 
> > +struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
> > +{
> > +	struct cpsw_ale *ale;
> > +	int ret;
> > +
> > +	ret = -ENOMEM;
> > +	ale = kzalloc(sizeof(*ale), GFP_KERNEL);
> > +	if (WARN_ON(!ale))
> > +		return NULL;
> 
> The WARN_ON is unnecessary.  alloc failures get a dump_stack.

You mean kzalloc will provide a dump stack during allocation failure, if so
I will remove the WARN_ON

> 
> > diff --git a/drivers/net/ethernet/ti/cpsw_ale.h
> b/drivers/net/ethernet/ti/cpsw_ale.h
> []
> > +struct cpsw_ale {
> > +	struct cpsw_ale_params	params;
> > +	struct timer_list	timer;
> > +	unsigned long		ageout;
> > +	struct device_attribute ale_control_attr;
> > +#define control_attr_to_ale(attr)	\
> > +	container_of(attr, struct cpsw_ale, ale_control_attr);
> > +	struct device_attribute ale_table_attr;
> > +#define table_attr_to_ale(attr)		\
> > +	container_of(attr, struct cpsw_ale, ale_table_attr);
> > +};
> 
> Embedding the #defines in a struct makes it difficult to read.
> Perhaps this is simpler:
> 
> struct cpsw_ale {
> 	struct cpsw_ale_params	params;
> 	struct timer_list	timer;
> 	unsigned long		ageout;
> 	struct device_attribute ale_control_attr;
> 	struct device_attribute ale_table_attr;
> };
> 
> #define control_attr_to_ale(attr)	\
> 	container_of(attr, struct cpsw_ale, ale_control_attr);
> #define table_attr_to_ale(attr)		\
> 	container_of(attr, struct cpsw_ale, ale_table_attr);
> 

Yes, I will move the define outside struct definition in next set of
patch set.

> 

With regards
Mugunthan V N
