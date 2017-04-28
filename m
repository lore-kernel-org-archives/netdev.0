From: Sricharan R <sricharan@codeaurora.org>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Fri, 28 Apr 2017 17:26:41 +0530
Message-ID: <bcdcc1cc-181c-8396-dd3c-dd40d0c7efc1@codeaurora.org>
References: <20170426181508.687b52af@gmail.com>
 <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
 <20170427164014.422a124c@gmail.com>
 <524b7fc8-1eca-a7d8-7bc7-6743be17c208@codeaurora.org>
 <20170428081919.21bb569d@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------70DED1DF94E9EA11BD3E2B91"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Joerg Roedel <jroedel@suse.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Ralph Sennhauser <ralph.sennhauser@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170428081919.21bb569d@gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------70DED1DF94E9EA11BD3E2B91
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi Ralph,

<snip..>

>>>>>
>>>>> Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe
>>>>> time for platform/amba/pci bus devices") causes a kernel panic as
>>>>> in the log below on an armada-385. Reverting the commit fixes the
>>>>> issue.
>>>>>
>>>>> Regards
>>>>> Ralph    
>>>>
>>>> Somehow not getting a obvious clue on whats going wrong with the
>>>> logs below. From the log and looking in to dts, the drivers seems
>>>> to the one for "marvell,armada-370-neta".  
>>>
>>> Correct.
>>>   
>>>> Issue looks the data from the dma
>>>> has gone bad and subsequently referring the wrong data has resulted
>>>> in the crash. Looks like the dma_masks is the one going wrong.
>>>> Can i get some logs from mvneta_probe, about dev->dma_mask,
>>>> dev->coherent_dma_mask and dev->dma_ops with and without the patch
>>>> to see whats the difference ?  
>>>
>>> Not sure I understood what exactly you are after. Might be faster to
>>> just send me a patch with all debug print statements you like to
>>> see. 
>>
>> Attached the patch with debug prints.
>>
>> Regards,
>>  Sricharan
>>
> 
> Hi Sricharan
> 
> With commit 09515ef5ddad
> 
> [    1.288962] mvneta f1070000.ethernet: dev->dma_mask 0xffffffff
> [    1.294827] mvneta f1070000.ethernet: dev->coherent_dma_mask 0xffffffff
> [    1.301472] mvneta f1070000.ethernet: dev->dma_ops 0x40b00c0601460
> 
> [    1.322047] mvneta f1034000.ethernet: dev->dma_mask 0xffffffff
> [    1.327904] mvneta f1034000.ethernet: dev->coherent_dma_mask 0xffffffff
> [    1.334549] mvneta f1034000.ethernet: dev->dma_ops 0x40b00c0601460
> 
> 
> With the patch reverted, the build that works
> 
> [    1.289001] mvneta f1070000.ethernet: dev->dma_mask 0xffffffff
> [    1.294866] mvneta f1070000.ethernet: dev->coherent_dma_mask 0xffffffff
> [    1.301511] mvneta f1070000.ethernet: dev->dma_ops 0x40b00c06014a8
> 
> [    1.317005] mvneta f1034000.ethernet: dev->dma_mask 0xffffffff
> [    1.322867] mvneta f1034000.ethernet: dev->coherent_dma_mask 0xffffffff
> [    1.329508] mvneta f1034000.ethernet: dev->dma_ops 0x40b00c06014a8
> 

My bad, i think it is this patch missing [1], attached it as well.
Infact, this was in the series initially and got acked to get merged
separately well before the series. I should have sent this to Russell.
I will do this now. If this fixes up the issue,
i will take this patch separately, while this series gets tested
on -next.

[1] https://patchwork.kernel.org/patch/9362113/

-- 
"QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation

--------------70DED1DF94E9EA11BD3E2B91
Content-Type: text/plain; charset=UTF-8;
 name="0001-arm-dma-mapping-Don-t-override-dma_ops-in-arch_setup.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="0001-arm-dma-mapping-Don-t-override-dma_ops-in-arch_setup.pa";
 filename*1="tch"

RnJvbSBiZTM2ZWE1ZjJjN2QxYzI4ZGM4ZjgyOWI1ZDJjODE3ODI2NDgxMDg2IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBMYXVyZW50IFBpbmNoYXJ0IDxsYXVyZW50LnBpbmNo
YXJ0K3JlbmVzYXNAaWRlYXNvbmJvYXJkLmNvbT4KRGF0ZTogRnJpLCAxNSBNYXkgMjAxNSAw
MjowMDowMiArMDMwMApTdWJqZWN0OiBbUEFUQ0hdIGFybTogZG1hLW1hcHBpbmc6IERvbid0
IG92ZXJyaWRlIGRtYV9vcHMgaW4KIGFyY2hfc2V0dXBfZG1hX29wcygpCgpUaGUgYXJjaF9z
ZXR1cF9kbWFfb3BzKCkgZnVuY3Rpb24gaXMgaW4gY2hhcmdlIG9mIHNldHRpbmcgZG1hX29w
cyB3aXRoIGEKY2FsbCB0byBzZXRfZG1hX29wcygpLiBzZXRfZG1hX29wcygpIGlzIGFsc28g
Y2FsbGVkIGZyb20KCi0gaGlnaGJhbmsgYW5kIG12ZWJ1IGJ1cyBub3RpZmllcnMKLSBkbWFi
b3VuY2UgKHRvIGJlIHJlcGxhY2VkIHdpdGggc3dpb3RsYikKLSBhcm1faW9tbXVfYXR0YWNo
X2RldmljZQoKKGFybV9pb21tdV9hdHRhY2hfZGV2aWNlIGlzIGl0c2VsZiBjYWxsZWQgZnJv
bSBJT01NVSBhbmQgYnVzIG1hc3RlcgpkZXZpY2UgZHJpdmVycykKClRvIGFsbG93IHRoZSBh
cmNoX3NldHVwX2RtYV9vcHMoKSBjYWxsIHRvIGJlIG1vdmVkIGZyb20gZGV2aWNlIGFkZCB0
aW1lCnRvIGRldmljZSBwcm9iZSB0aW1lIHdlIG11c3QgZW5zdXJlIHRoYXQgZG1hX29wcyBh
bHJlYWR5IHNldHVwIGJ5IGFueSBvZgp0aGUgYWJvdmUgY2FsbGVycyB3aWxsIG5vdCBiZSBv
dmVycmlkZW4uCgpBZnRlcmluZyByZXBsYWNpbmcgZG1hYm91bmNlIHdpdGggc3dpb3RsYiwg
Y29udmVydGluZyBJT01NVSBkcml2ZXJzIHRvCm9mX3hsYXRlIGFuZCB0YWtpbmcgY2FyZSBv
ZiBoaWdoYmFuayBhbmQgbXZlYnUsIHRoZSB3b3JrYXJvdW5kIHNob3VsZCBiZQpyZW1vdmVk
LgoKW1JlYmFzZWQgb24gdG9wIG9mIDQuMTEtcmM4XQpTaWduZWQtb2ZmLWJ5OiBTcmljaGFy
YW4gUiA8c3JpY2hhcmFuQGNvZGVhdXJvcmEub3JnPgpTaWduZWQtb2ZmLWJ5OiBMYXVyZW50
IFBpbmNoYXJ0IDxsYXVyZW50LnBpbmNoYXJ0K3JlbmVzYXNAaWRlYXNvbmJvYXJkLmNvbT4K
LS0tCiBhcmNoL2FybS9tbS9kbWEtbWFwcGluZy5jIHwgOSArKysrKysrKysKIDEgZmlsZSBj
aGFuZ2VkLCA5IGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9hcmNoL2FybS9tbS9kbWEt
bWFwcGluZy5jIGIvYXJjaC9hcm0vbW0vZG1hLW1hcHBpbmcuYwppbmRleCAwMjY4NTg0Li5j
NzQyZGZkIDEwMDY0NAotLS0gYS9hcmNoL2FybS9tbS9kbWEtbWFwcGluZy5jCisrKyBiL2Fy
Y2gvYXJtL21tL2RtYS1tYXBwaW5nLmMKQEAgLTI0MDgsNiArMjQwOCwxNSBAQCB2b2lkIGFy
Y2hfc2V0dXBfZG1hX29wcyhzdHJ1Y3QgZGV2aWNlICpkZXYsIHU2NCBkbWFfYmFzZSwgdTY0
IHNpemUsCiAJY29uc3Qgc3RydWN0IGRtYV9tYXBfb3BzICpkbWFfb3BzOwogCiAJZGV2LT5h
cmNoZGF0YS5kbWFfY29oZXJlbnQgPSBjb2hlcmVudDsKKworCS8qCisJICogRG9uJ3Qgb3Zl
cnJpZGUgdGhlIGRtYV9vcHMgaWYgdGhleSBoYXZlIGFscmVhZHkgYmVlbiBzZXQuIElkZWFs
bHkKKwkgKiB0aGlzIHNob3VsZCBiZSB0aGUgb25seSBsb2NhdGlvbiB3aGVyZSBkbWFfb3Bz
IGFyZSBzZXQsIHJlbW92ZSB0aGlzCisJICogY2hlY2sgd2hlbiBhbGwgb3RoZXIgY2FsbGVy
cyBvZiBzZXRfZG1hX29wcyB3aWxsIGhhdmUgZGlzYXBwZWFyZWQuCisJICovCisJaWYgKGRl
di0+ZG1hX29wcykKKwkJcmV0dXJuOworCiAJaWYgKGFybV9zZXR1cF9pb21tdV9kbWFfb3Bz
KGRldiwgZG1hX2Jhc2UsIHNpemUsIGlvbW11KSkKIAkJZG1hX29wcyA9IGFybV9nZXRfaW9t
bXVfZG1hX21hcF9vcHMoY29oZXJlbnQpOwogCWVsc2UKLS0gClFVQUxDT01NIElORElBLCBv
biBiZWhhbGYgb2YgUXVhbGNvbW0gSW5ub3ZhdGlvbiBDZW50ZXIsIEluYy4gaXMgYSBtZW1i
ZXIgb2YgQ29kZSBBdXJvcmEgRm9ydW0sIGhvc3RlZCBieSBUaGUgTGludXggRm91bmRhdGlv
bgoK
--------------70DED1DF94E9EA11BD3E2B91--
