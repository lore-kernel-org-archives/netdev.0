From: "Winkler, Tomas" <tomas.winkler@intel.com>
Subject: RE: [PATCH v3 5/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Sat, 16 Jul 2016 08:43:56 +0000
Message-ID: <5B8DA87D05A7694D9FA63FD143655C1B54295BCA@hasmsx108.ger.corp.intel.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
 <1468495702-7467-6-git-send-email-amir.jer.levy@intel.com>
 <5B8DA87D05A7694D9FA63FD143655C1B54294E4A@hasmsx108.ger.corp.intel.com>
 <E607265CB020454880711A6F96C05A03893CD38E@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>,
	"andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23575 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbcGPIoD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 04:44:03 -0400
In-Reply-To: <E607265CB020454880711A6F96C05A03893CD38E@hasmsx107.ger.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Levy, Amir (Jer)
> Sent: Thursday, July 14, 2016 17:50
> To: Winkler, Tomas <tomas.winkler@intel.com>;
> andreas.noever@gmail.com; gregkh@linuxfoundation.org;
> bhelgaas@google.com
> Cc: linux-pci@vger.kernel.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; thunderbolt-linux <thunderbolt-linux@intel.com>;
> Westerberg, Mika <mika.westerberg@intel.com>
> Subject: RE: [PATCH v3 5/8] thunderbolt: Communication with the ICM
> (firmware)
> 
> Hi Tomas,
> Thanks for your comments.
> 
> On Thu, Jul 14 2016, 03:44 PM, Winkler, Tomas wrote:
> > > +/* NHI genetlink commands */
> > > +enum {
> > > +	NHI_CMD_UNSPEC,
> > > +	NHI_CMD_SUBSCRIBE,
> > > +	NHI_CMD_UNSUBSCRIBE,
> > > +	NHI_CMD_QUERY_INFORMATION,
> > > +	NHI_CMD_MSG_TO_ICM,
> > > +	NHI_CMD_MSG_FROM_ICM,
> > > +	NHI_CMD_MAILBOX,
> > > +	NHI_CMD_APPROVE_TBT_NETWORKING,
> > > +	NHI_CMD_ICM_IN_SAFE_MODE,
> > > +	__NHI_CMD_MAX,
> > > +};
> > > +#define NHI_CMD_MAX (__NHI_CMD_MAX - 1)
> > NHI_CMD_MAX  = NHI_CMD_ICM_IN_SAFE_MODE ?
> >
> 
> This template is used a lot with (generic) netlink.
> Few examples:
> http://lxr.free-electrons.com/source/drivers/acpi/event.c#L62
> http://lxr.free-electrons.com/source/include/uapi/linux/irda.h#L224
> It is easier to maintain - adding entry in the list will automatically update
> MAX.

Fair enough. 

> [...]
> 
> > > +		u32 status;
> > > +
> > > +		status = ioread32(nhi_ctxt->iobase + REG_FW_STS);
> > > +
> > > +		if (status & REG_FW_STS_NVM_AUTH_DONE)
> > > +			break;
> > > +		msleep(30);
> >
> > 30 is  big number, for polling, what is behind this?
> >
> 
> The NVM authentication can take time for ICM.
> This number comes from experiments.

This deserve some comment, this look very random. 
 
> [...]
> 
> > > +static struct tbt_nhi_ctxt *nhi_search_ctxt(u32 id) {
> > > +	struct tbt_nhi_ctxt *nhi_ctxt;
> > > +
> > > +	list_for_each_entry(nhi_ctxt, &controllers_list, node)
> > > +		if (nhi_ctxt->id == id)
> > > +			return nhi_ctxt;
> >
> > Don't you need to lock this list with the controllers_list_rwsem ?
> >
> 
> This is a helper function for searching the list.
> The callers take and release the lock.

Since this doesn't fit the patterns in your code, the function deserves a comment, that it should be used under lock. 

> 
> [...]
> 
> > > +	bool nvm_auth_on_boot : 1;
> > Don't use bool with bit fields use u32
> 
> What is the concern here?
> If it is size of bool, it doesn't matter for this struct.
> It is more readable that the expected value is bool, and it is used a lot in
> kernel, for example:
> http://lxr.free-electrons.com/source/include/linux/pm.h#L558

Hmm, actually a nice feature I wasn't aware of, save some space and got bool type checking. 

Thanks
