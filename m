From: Hyong-Youb Kim <hyong-youb.kim@myricom.com>
Subject: Re: [PATCH 20/34] myri10ge: Use pci_enable_msix_range()
Date: Sat, 1 Feb 2014 23:13:34 +0900
Message-ID: <52ED010E.80500@myricom.com>
References: <cover.1391172839.git.agordeev@redhat.com> <1253b3c920637ab6bb987defb88d1698ac1e4851.1391172839.git.agordeev@redhat.com> <52EBF885.30309@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexander Gordeev <agordeev@redhat.com>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EBF885.30309@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2/1/2014 4:24 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 01/31/2014 06:08 PM, Alexander Gordeev wrote:
>
[...]
>> +        if (status < 0)
>> +            goto disable_msix;
>
>     Hm, if enabling MSI failed, we don't need to disable it, right? So,
> perhaps the label should be renamed?
>

The code following disable_msix does not call pci_disable_msix().  It 
frees the allocated vector buffer and loads the firmware that uses a 
single interrupt vector.  So, it is "disable" in the sense that the 
driver is not going to use MSI-X vectors.  I agree that naming could be 
better.

disable_msix:
         if (mgp->msix_vectors != NULL) {
                 kfree(mgp->msix_vectors);
                 mgp->msix_vectors = NULL;
         }

abort_with_fw:
         mgp->num_slices = 1;
         set_fw_name(mgp, old_fw, old_allocated);
         myri10ge_load_firmware(mgp, 0);
