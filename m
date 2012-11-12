From: Don Dutile <ddutile@redhat.com>
Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources
 for SR-IOV)
Date: Mon, 12 Nov 2012 14:46:59 -0500
Message-ID: <50A15233.10007@redhat.com>
References: <201211081915083774239@gmail.com> <509B962C.6070002@gmail.com> <C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com> <CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com> <CAErSpo4xn9t=4yXGLdPQMtUJF=n38tYrMutAoj7NCsLUzQEbcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Gao <pkill.2012@gmail.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, linux-pci@vger.kernel.org,
	Yinghai Lu <yinghai@kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo4xn9t=4yXGLdPQMtUJF=n38tYrMutAoj7NCsLUzQEbcg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/2012 10:26 AM, Bjorn Helgaas wrote:
> [+ linux-pci, Yinghai]
>
> On Thu, Nov 8, 2012 at 8:59 PM, Jason Gao<pkill.2012@gmail.com>  wrote:
>>> The BIOS in your machine doesn't support SR-IOV.  You'll need to ask the manufacturer for a BIOS upgrade, if in fact one is available.  Sometimes they're not.
>>
>> very thanks Greg,my server Dell R710 with latest BIOS version and
>> option for SR-IOV(SR-IOV Global Enable->Enabled)  opened,I'm confused
>> that Does R710 provide full support for SR-IOV, kernel or  ixgbe
>> driver's bug? but I'm not sure where the problem lies,anyone has any
>> experience about this?   .
>
> Linux normally uses the resource assignments done by the BIOS, but it
> is possible for the kernel to reassign those.  We don't have good
> automatic support for that yet, but on a recent upstream kernel, you
> can try "pci=realloc".  I doubt this option is in CentOS 6.3, though.
>
Try moving the device into a different slot.
You may be trying it in a non-ARI slot in the 710; that is a problem
in RHEL6 (needing to realloc bus &/or mem-space).
A non-ARI slot will want to use one bus number per VF.... which will
be problematic.
I know I've seen ixgbe's (& their vfs's) working on a dell 710;
but they may also be one of those systems that has a slot off the ich10
with no ARI support.

> If an upstream kernel with "pci=realloc" still doesn't work, please
> post the entire dmesg log.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
