From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH -net] scsi: fix users of SCSI_FC_ATTRS to depend on NET
Date: Tue, 16 Sep 2014 13:24:46 -0700
Message-ID: <54189C8E.5030409@infradead.org>
References: <5417DA29.4060205@infradead.org> <20140916.161518.620276378147910368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	jbottomley@parallels.com, fengguang.wu@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140916.161518.620276378147910368.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/16/14 13:15, David Miller wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> Date: Mon, 15 Sep 2014 23:35:21 -0700
> 
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> There are other kconfig symbols which select SCSI_FC_ATTRS,
>> so they also need to depend on NET to fix kconfig warnings and
>> build errors:
>>
>> warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has unmet direct dependencies (SCSI && NET)
>> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
>> drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared (first use in this function)
>> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
>> drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared (first use in this function)
>>
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> 
> Randy, this is starting to get convoluted.

Yes, I'm not happy about it either.

> It's pretty much pointless for SCSI_FC_ATTRS to depend on NET itself
> if we have to explicitly place a NET dependency on every single user
> of SCSI_FC_ATTRS.
> 
> We have expressed a proper dependency for SCSI_FC_ATTRS only to have
> it forcefully bypassed by every single user because we 'select' it
> instead of using 'depends'.
> 
> Can we just change these 'select' operations on SCSI_FC_ATTRS to just
> be 'depends' instead?
> 
> I really wouldn't mind if select had the effect of force enabling the
> dependencies of the select'd Kconfig symbol.  Then it really does what
> we use it for (keeping the user from having to know obscure
> dependencies just to enable the feature they want) without the ugly
> side effect of dependency bypassing.
> 
> So a "select" would do a recursive "select" on all the dependencies
> needed to turn on the select'd object.
> 
> I doubt it would even need to recurse often at all, the ways we use
> this is almost always to turn on some top level major piece of
> infrastructure.
> 
> Anyways, that's a longer term thing and we need to fix this now, any
> opinions on just using 'depend SCSI_FX_ATTRS' to fix this?

typo:                     depends on SCSI_FC_ATTRS

No, I certainly have no objection and prefer depends over select anyway.

-- 
~Randy
