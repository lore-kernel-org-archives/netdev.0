From: Sricharan R <sricharan@codeaurora.org>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Fri, 28 Apr 2017 09:59:32 +0530
Message-ID: <0a3e7a85-babb-8ae7-2c19-480c5203a8e5@codeaurora.org>
References: <20170426181508.687b52af@gmail.com>
 <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------147DF2B73712B6B592606189"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Joerg Roedel <jroedel@suse.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Ralph Sennhauser <ralph.sennhauser@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
Content-Language: en-US
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------147DF2B73712B6B592606189
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi Ralph,

On 4/27/2017 7:05 PM, Sricharan R wrote:
> Hi,
> 
> On 4/26/2017 9:45 PM, Ralph Sennhauser wrote:
>> Hi Sricharan R,
>>
>> Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe time
>> for platform/amba/pci bus devices") causes a kernel panic as in the log
>> below on an armada-385. Reverting the commit fixes the issue.
>>
>> Regards
>> Ralph
> 
> Somehow not getting a obvious clue on whats going wrong with the logs
> below. From the log and looking in to dts, the drivers seems to the one for
> "marvell,armada-370-neta". Issue looks the data from the dma has gone bad
> and subsequently referring the wrong data has resulted in the crash.
> Looks like the dma_masks is the one going wrong.
> Can i get some logs from mvneta_probe, about dev->dma_mask,
> dev->coherent_dma_mask and dev->dma_ops with and without the patch
> to see whats the difference ?
> 

Attached the patch with debug prints.

Regards,
 Sricharan

--------------147DF2B73712B6B592606189
Content-Type: text/plain; charset=UTF-8;
 name="0001-Debug-prints.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-Debug-prints.patch"

RnJvbSBmZTc3ZDM5NjhkNmJjMzViNDZlNWYzMGQ1YzY3Yzc2MDNhYTEwNTk3IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBTcmljaGFyYW4gUiA8c3JpY2hhcmFuQGNvZGVhdXJv
cmEub3JnPgpEYXRlOiBGcmksIDI4IEFwciAyMDE3IDA5OjQzOjI2ICswNTMwClN1YmplY3Q6
IFtQQVRDSF0gRGVidWcgcHJpbnRzCgpTaWduZWQtb2ZmLWJ5OiBTcmljaGFyYW4gUiA8c3Jp
Y2hhcmFuQGNvZGVhdXJvcmEub3JnPgotLS0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L21hcnZl
bGwvbXZuZXRhLmMgfCA2ICsrKysrKwogMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygr
KQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L21hcnZlbGwvbXZuZXRhLmMg
Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9tYXJ2ZWxsL212bmV0YS5jCmluZGV4IGQyOTcwMTEu
LjI1MGYwYjIgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L21hcnZlbGwvbXZu
ZXRhLmMKKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWFydmVsbC9tdm5ldGEuYwpAQCAt
NDE0Niw2ICs0MTQ2LDEyIEBAIHN0YXRpYyBpbnQgbXZuZXRhX3Byb2JlKHN0cnVjdCBwbGF0
Zm9ybV9kZXZpY2UgKnBkZXYpCiAJaW50IHBoeV9tb2RlOwogCWludCBlcnI7CiAJaW50IGNw
dTsKKwlzdHJ1Y3QgZGV2aWNlICpkZGV2ID0gJnBkZXYtPmRldjsKKworCisJZGV2X2Vycihk
ZGV2LCAiZGV2LT5kbWFfbWFzayAweCVsbHhcbiIsICooZGRldi0+ZG1hX21hc2spKTsKKwlk
ZXZfZXJyKGRkZXYsICJkZXYtPmNvaGVyZW50X2RtYV9tYXNrIDB4JWxseFxuIiwgZGRldi0+
Y29oZXJlbnRfZG1hX21hc2spOworCWRldl9lcnIoZGRldiwgImRldi0+ZG1hX29wcyAweCVs
bHhcbiIsIGRkZXYtPmRtYV9vcHMpOwogCiAJZGV2ID0gYWxsb2NfZXRoZXJkZXZfbXFzKHNp
emVvZihzdHJ1Y3QgbXZuZXRhX3BvcnQpLCB0eHFfbnVtYmVyLCByeHFfbnVtYmVyKTsKIAlp
ZiAoIWRldikKLS0gClFVQUxDT01NIElORElBLCBvbiBiZWhhbGYgb2YgUXVhbGNvbW0gSW5u
b3ZhdGlvbiBDZW50ZXIsIEluYy4gaXMgYSBtZW1iZXIgb2YgQ29kZSBBdXJvcmEgRm9ydW0s
IGhvc3RlZCBieSBUaGUgTGludXggRm91bmRhdGlvbgoK
--------------147DF2B73712B6B592606189--
