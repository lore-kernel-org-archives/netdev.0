From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 24 Sep 2012 13:37:34 -0400
Message-ID: <50609A5E.7020104@redhat.com>
References: <5003DC9B.8000706@broadcom.com> <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com> <500D6932.8090306@genband.com> <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net> <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com> <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown> <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com> <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com> <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A07152FA5F6@ORSMSX106.amr.corp.intel.com> <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com> <505CAC93.8020304@r
 edhat.com> <CAE9FiQW4vY3SwAt1TGhSa=bcmKnzxS96b9HGoU5_CDb3FRvGVA@mail.gmail.com> <505CC930.5070807@redhat.com> <505F2F99.9090302@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <505F2F99.9090302@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2012 11:49 AM, Yuval Mintz wrote:
>>>> It provides 3 sysfs files (enable, disable, num_max_vfs);
>>>> callbacks for enable&   disable.
>>>
>>> why using three? only pass max_vfs should be enough...
>>>
>>> aka pass 0 mean disabling, pass other value mean enabling.
>>>
>> could do that.  but I wouldn't use 'max_vfs'; I would recommend
>> 'num_vfs', as max implies, er, um, the maximum, and what one
>> wants is to be able to enable a number from 1->max_vfs.
>> 'max_vfs' will be provided by another file.
>>
>
> If we're at it, how do you suggest the configurations of the VFs
> resources/properties should be made?
> Notice I'm asking about properties which relate to all PCI devices,
> E.g., number of interrupts assigned to each VF (for VF RSS).
>
This issue/question is indep of VFs & SRIOV.
It's a generic problem for PFs and how many (msi) intr's a device
is given, based on its request, i.e., system provides 8 MSI per cpu
per device ... how are those 8 assigned/used by the device? ...
how to free 4 of the 8 if one device doesn't use them, and another
device could use them..   cache/memory affinity to intr's.... the list
goes on...

> (For properties which relate only to networking devices, we could
> use standard network API such as netlink).
>
> Perhaps given a configurable property that applies to all PCI devices,
A VF is 'just another PCI device', so configurable properties
for all PCI devices should encompass VF/SRIOV devices equally.

> once SRIOV is enabled and the VFs are created, there would be an
> additional sysfs node under the VFs through which the user could
> configure that property.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
