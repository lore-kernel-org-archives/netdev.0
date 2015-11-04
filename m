From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 5 Nov 2015 01:06:36 +0200
Message-ID: <CAHp75VfiveeZQ=gKDo7ZbySowrxxNNaC7=ZQriU0m-oVEQ92Kw@mail.gmail.com>
References: <20151104193956.GD14575@oracle.com>
	<CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
	<FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f193.google.com ([209.85.160.193]:35364 "EHLO
	mail-yk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030396AbbKDXGh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 18:06:37 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 5, 2015 at 12:53 AM, Nelson, Shannon
<shannon.nelson@intel.com> wrote:
>> From: Andy Shevchenko [mailto:andy.shevchenko@gmail.com]
>> Sent: Wednesday, November 04, 2015 11:59 AM
>>
>> On Wed, Nov 4, 2015 at 9:39 PM, Sowmini Varadhan
>> <sowmini.varadhan@oracle.com> wrote:
>> >
>> > This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
>> > address in Open Firmware or IDPROM").
>
> [...]
>
>> > +       }
>> > +
>> > +       memset(&element, 0, sizeof(element));
>> > +       ether_addr_copy(element.mac_addr, macaddr);
>> > +       element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
>> > +       ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element,
>> 1, NULL);
>> > +       aq_err = vsi->back->hw.aq.asq_last_status;
>>
>> Do you really need a separate variable (aq_err)?
>
> These are two separate error values that we're tracking - one from the communication between the driver and the firmware (aq_err) and one from the driver activity.  Sometimes there may be an AQ error that we want to report, but it might not actually be a driver error.  Alternatively, there are times when the AQ error needs to get interpreted different ways depending on which task the driver is performing.  Lastly, the AQ error gives us more detail on whatever the transaction error may have been which gives us more useful debug info.

Understandable, though in this certain function I don't see why we
can't drop it. The usage of it like this:

var x;

x = y;
if (x) {
...
}

Which is just
if (y) {
...
}


>
> sln



-- 
With Best Regards,
Andy Shevchenko
