From: Dean Nelson <dnelson@redhat.com>
Subject: Re: [PATCH 0/3] pci: fix/cleanup pcix get and set mmrbc functions
Date: Mon, 15 Mar 2010 05:59:55 -0500
Message-ID: <4B9E132B.4050105@redhat.com>
References: <20100310032632.6331.15414.send-patch@aqua> <20100312170000.55cc055a@jbarnes-piketon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100312170000.55cc055a@jbarnes-piketon>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/12/2010 07:00 PM, Jesse Barnes wrote:
> On Tue, 9 Mar 2010 22:26:33 -0500
> Dean Nelson<dnelson@redhat.com>  wrote:
>
>> A customer running RHEL4.8 encountered
>>
>>   "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"
>>
>> type errors, which were determined to be the result of a bad return value
>> from e1000_pcix_get_mmrbc() causing the call to e1000_pcix_set_mmrbc() to
>> be skipped in the following snippet of code from e1000_init_hw().
>>
>> 	switch (hw->mac_type) {
>> 	case e1000_82545_rev_3:
>> 	case e1000_82546_rev_3:
>> 		break;
>> 	default:
>> 		/* Workaround for PCI-X problem when BIOS sets MMRBC incorrectly. */
>> 		if (hw->bus_type == e1000_bus_type_pcix
>> 		&&  e1000_pcix_get_mmrbc(hw)>  2048)
>> 			e1000_pcix_set_mmrbc(hw, 2048);
>> 		break;
>> 	}
>>
>> e1000_pcix_get_mmrbc() is basically a wrapper for a call to pcix_get_mmrbc().
>> e1000_pcix_set_mmrbc() is the same for pcix_set_mmrbc().
>>
>> The following three patches are a response to the problems that were found to
>> exist with pcix_get_max_mmrbc(), pcix_get_mmrbc() and pcix_set_mmrbc().
>>
>> Versions of these patches applicable to RHEL4 were verified by the customer to
>> solve their problem.
>
> Thanks Dean, I'll pull these in and send them to Linus for 2.6.34.  I
> assume they should also be included in the stable kernel series?  If
> so, I'll add a cc: stable@kernel.org when I commit them.

Yes, they should also be included in the stable kernel series. Thanks so 
much Jesse.

Dean
