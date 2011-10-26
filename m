From: Kelvin Cheung <keguang.zhang@gmail.com>
Subject: Re: [PATCH V2 2/4] MIPS: Add board support for Loongson1B
Date: Wed, 26 Oct 2011 12:27:42 +0800
Message-ID: <CAJhJPsU3KMNuGcKaKf3H4pUCeu1+vnEz4DgO_jbm+wDQb1G4OA@mail.gmail.com>
References: <1319192888-21465-1-git-send-email-keguang.zhang@gmail.com>
	<1319192888-21465-2-git-send-email-keguang.zhang@gmail.com>
	<CAD+V5YKBkW52_md9rBeVZ1RXq2FGEXt=Ergsw+z8txMreZdNsA@mail.gmail.com>
	<4EA5117C.3000402@st.com>
	<CAJhJPsVSzXXmBOwLaGNtOsxhVEyC0fAJtiBvEWzcKcSDC8NEcA@mail.gmail.com>
	<4EA557B2.4020504@st.com>
	<CAJhJPsXxUAuF9HdivLd66MQC45mz-iYAuF1SdGdU=-duxJJ5bQ@mail.gmail.com>
	<4EA585B5.5030405@st.com>
	<CAJhJPsVu7hahhmUvPQ=s=AqvXGhU-05x=GqQ29Mo6PZ8cTtefA@mail.gmail.com>
	<4EA660C0.1020901@st.com>
	<4EA6716A.80307@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30780d00b7076804b02c13c9
Cc: Wu Zhangjin <wuzhangjin@gmail.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	r0bertz@gentoo.org, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EA6716A.80307@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--20cf30780d00b7076804b02c13c9
Content-Type: text/plain; charset=ISO-8859-1

Hi Giuseppe,

This patch works well on Loongson1B platform except one thing.
The rx checksum offload of normal descriptor is disabled by default.
So, I enabled this functon. And one minor tweak is added to your patch.
What about your opinion?

BTW, tx checksum insertion works now.

2011/10/25, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
> On 10/25/2011 9:09 AM, Giuseppe CAVALLARO wrote:
>> On 10/25/2011 4:12 AM, Kelvin Cheung wrote:
>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>> On 10/24/2011 4:05 PM, Kelvin Cheung wrote:
>>>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>>>> Hello Kelvin.
>>>>>>
>>>>>> On 10/24/2011 12:36 PM, Kelvin Cheung wrote:
>>>>>>
>>>>>> [snip]
>>>>>>
>>>>>>> According to datasheet of Loongson 1B, the buffer size in RX/TX
>>>>>>> descriptor is only 2KB. So the Loongson1B's GMAC could not handle
>>>>>>> jumbo frames. And the second buffer is useless in this case. Am I
>>>>>>> right? Is there a better way than ifdef CONFIG_MACH_LOONGSON1 to
>>>>>>> avoid duplicate code?
>>>>>>
>>>>>> Sorry for my misunderstanding.
>>>>>>
>>>>>> I think you have to use the normal descriptor and remove the enh_desc
>>>>>> from the platform w/o modifying the driver at all.
>>>>>>
>>>>>> The driver will be able to select/configure all automatically (also
>>>>>> jumbo).
>>>>>>
>>>>>> Let me know.
>>>>>
>>>>> That's the problem.
>>>>> The bitfield definition of Loongson1B is also different from normal
>>>>> descriptor.
>>>>
>>>> The problem is not in the Loongson1B gmac.
>>>
>>> I found that the bit checksum_insertion is not existed in normal
>>> descriptor.
>>>
>>>> The normal descriptor fields in the stmmac refer to an old synopsys
>>>> databook.
>>>
>>> Could you send me the new databook of Synopsys GMAC?
>>>
>>>> New chips have the same structure you have added; so we should fix this
>>>> in the driver w/o breaking the compatibility for old chips.
>>>
>>> Agree.
>>>
>>>> I kindly ask you to confirm if the currently normal descriptor structure
>>>> (w/o your changes) doesn't work on your platform.
>>>> Did you test it?
>>>
>>> Well, the normal descriptor works on my platform except TX checksum
>>> offload.
>>
>> ok! I suspected that.
>>
>>
>>>>> Moreover, I want to enable the TX checksum offload function which is
>>>>> not supported in normal descriptor.
>>>>> Any suggestions?
>>>>
>>>> It is supported but you have to pass from the platform: tx_coe = 1.
>>>
>>> I noticed that the flag csum_insertion is passed to
>>> ndesc_prepare_tx_desc() in stmmac_xmit(). But ndesc_prepare_tx_desc()
>>> just ignores it.
>>> In other words, the TX checksum offload function is disabled in normal
>>> descriptor currently.
>>>
>>> Should we fix this problem for normal descriptor?
>>
>> Yes, we should. If you agree, I'll update the normal descriptor
>> structure to yours. This is the normal descriptor used in newer GMAC.
>> Tx csum will be done for normal descriptors in case of these GMAC
>> devices and not for old MAC10/100. For the MAC10/100 some bits for
>> normal descriptors are reserved and won't be used at all.
>>
>> I'll also verify that the patch doesn't break the back-compatibility
>> with old MAC10/100. I have the HW where doing the tests.
>>
>> After that, I'll prepare the patch for net-next and for your kernel.
>
> Hello Kelvin
>
> attached the patch tested on my development kernel.
> It runs fine on old and new mac devices.
>
> Can you try it on your side? Hmm, it is likely it won't apply fine on
> your tree but you know the changes ;-).
>
> If ok, I'll rework it for net-next and send it to the mailing list.
>
> Thanks
> Peppe
>
>>
>>>
>>>> Peppe
>>>>>
>>>>>> Note:
>>>>>> IIRC, there is a bit difference in case of normal descriptors for
>>>>>> Synopsys databook newer than the 1.91 (I used for testing this mode).
>>>>>> In any case, I remember that, on some platforms, the normal
>>>>>> descriptors
>>>>>> have been used w/o problems also on these new chip generations.
>>>>>>
>>>>>> Peppe
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>


-- 
Best Regards!
Kelvin

--20cf30780d00b7076804b02c13c9
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-stmmac-update-normal-descriptor-structure.patch"
Content-Disposition: attachment;
	filename="0001-stmmac-update-normal-descriptor-structure.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: file0

RnJvbSA5M2VlM2VmZmJkZTYxMDEzYTg4NmQ1NzlmYzg5YzM2ZGRkZGIzNWE0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBLZWx2aW4gQ2hldW5nIDxrZWd1YW5nLnpoYW5nQGdtYWlsLmNv
bT4KRGF0ZTogV2VkLCAyNiBPY3QgMjAxMSAxMTowODowMSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IHN0bW1hYzogdXBkYXRlIG5vcm1hbCBkZXNjcmlwdG9yIHN0cnVjdHVyZQoKVGhpcyBwYXRjaCB1
cGRhdGVzIHRoZSBub3JtYWwgZGVzY3JpcHRvciBzdHJ1Y3R1cmUKdG8gd29yayBmaW5lIG9uIG5l
dyBHTUFDIFN5bm9wc3lzIGNoaXBzLgoKTm9ybWFsIGRlc2NyaXB0b3JzIHdlcmUgZGVzaWduZWQg
b24gdGhlIG9sZCBNQUMxMC8xMDAKZGF0YWJvb2sgMS45MSB3aGVyZSBzb21lIGJpdHMgd2VyZSBy
ZXNlcnZlZDogZm9yIGV4YW1wbGUKdGhlIHR4IGNoZWNrc3VtIGluc2VydGlvbiBhbmQgcnggY2hl
Y2tzdW0gb2ZmbG9hZC4KClRoZSBwYXRjaCBtYWludGFpbnMgdGhlIGJhY2stY29tcGF0aWJpbGl0
eSB3aXRoIG9sZApNQUMgZGV2aWNlcyAodGVzdGVkIG9uIFNUeDcxMDkgTUFDMTAvMTAwKSBhbmQg
YWRkcyBuZXcKZmllbGRzIHRoYXQgYWN0dWFsbHkgbmV3IEdNQUMgZGV2aWNlcyBjYW4gdXNlLgoK
Rm9yIGV4YW1wbGUsIFNUeDcxMDkgd2lsbCBwYXNzIGZyb20gdGhlIHBsYXRmb3JtCnR4X2NvZSA9
IDAsIGVuaF9kZXNjID0gMCwgaGFzX2dtYWMgPSAwLgpBIHBsYXRmb3JtIGxpa2UgTG9vbmdzb24x
QiAoTWlwcykgd2lsbCBwYXNzOgp0eF9jb2UgPSAxLCBlbmhfZGVzYyA9IDAsIGhhc19nbWFjID0g
MS4KClRoYW5rcyB0byBLZWx2aW4sIGhlIGVuaGFuY2VkIHRoZSBub3JtYWwgZGVzY3JpcHRvcnMg
Zm9yCkdNQUMgb24gTG9vbmdzb24xQi4KClNpZ25lZC1vZmYtYnk6IEtlbHZpbiBDaGV1bmcgPGtl
Z3VhbmcuemhhbmdAZ21haWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBHaXVzZXBwZSBDYXZhbGxhcm8g
PHBlcHBlLmNhdmFsbGFyb0BzdC5jb20+Ci0tLQogZHJpdmVycy9uZXQvc3RtbWFjL2NvbW1vbi5o
ICAgICAgICAgfCAgICA4ICsrKy0tLQogZHJpdmVycy9uZXQvc3RtbWFjL2Rlc2NzLmggICAgICAg
ICAgfCAgIDMxICsrKysrKysrKysrKysrKy0tLS0tLS0tLS0tCiBkcml2ZXJzL25ldC9zdG1tYWMv
bm9ybV9kZXNjLmMgICAgICB8ICAgNDAgKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0t
LQogZHJpdmVycy9uZXQvc3RtbWFjL3N0bW1hY19ldGh0b29sLmMgfCAgICA4ICsrKy0tLQogNCBm
aWxlcyBjaGFuZ2VkLCA0OCBpbnNlcnRpb25zKCspLCAzOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1n
aXQgYS9kcml2ZXJzL25ldC9zdG1tYWMvY29tbW9uLmggYi9kcml2ZXJzL25ldC9zdG1tYWMvY29t
bW9uLmgKaW5kZXggMzc1ZWExOS4uNmVjNGE4YyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvc3Rt
bWFjL2NvbW1vbi5oCisrKyBiL2RyaXZlcnMvbmV0L3N0bW1hYy9jb21tb24uaApAQCAtNDgsNyAr
NDgsNyBAQCBzdHJ1Y3Qgc3RtbWFjX2V4dHJhX3N0YXRzIHsKIAl1bnNpZ25lZCBsb25nIHR4X3Vu
ZGVyZmxvdyBfX19fY2FjaGVsaW5lX2FsaWduZWQ7CiAJdW5zaWduZWQgbG9uZyB0eF9jYXJyaWVy
OwogCXVuc2lnbmVkIGxvbmcgdHhfbG9zc2NhcnJpZXI7Ci0JdW5zaWduZWQgbG9uZyB0eF9oZWFy
dGJlYXQ7CisJdW5zaWduZWQgbG9uZyB2bGFuX3RhZzsKIAl1bnNpZ25lZCBsb25nIHR4X2RlZmVy
cmVkOwogCXVuc2lnbmVkIGxvbmcgdHhfdmxhbjsKIAl1bnNpZ25lZCBsb25nIHR4X2phYmJlcjsK
QEAgLTU3LDkgKzU3LDkgQEAgc3RydWN0IHN0bW1hY19leHRyYV9zdGF0cyB7CiAJdW5zaWduZWQg
bG9uZyB0eF9pcF9oZWFkZXJfZXJyb3I7CiAJLyogUmVjZWl2ZSBlcnJvcnMgKi8KIAl1bnNpZ25l
ZCBsb25nIHJ4X2Rlc2M7Ci0JdW5zaWduZWQgbG9uZyByeF9wYXJ0aWFsOwotCXVuc2lnbmVkIGxv
bmcgcnhfcnVudDsKLQl1bnNpZ25lZCBsb25nIHJ4X3Rvb2xvbmc7CisJdW5zaWduZWQgbG9uZyBz
YV9maWx0ZXJfZmFpbDsKKwl1bnNpZ25lZCBsb25nIG92ZXJmbG93X2Vycm9yOworCXVuc2lnbmVk
IGxvbmcgaXBjX2NzdW1fZXJyb3I7CiAJdW5zaWduZWQgbG9uZyByeF9jb2xsaXNpb247CiAJdW5z
aWduZWQgbG9uZyByeF9jcmM7CiAJdW5zaWduZWQgbG9uZyByeF9sZW5ndGg7CmRpZmYgLS1naXQg
YS9kcml2ZXJzL25ldC9zdG1tYWMvZGVzY3MuaCBiL2RyaXZlcnMvbmV0L3N0bW1hYy9kZXNjcy5o
CmluZGV4IDYzYTAzZTIuLjk4MjBlYzggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3N0bW1hYy9k
ZXNjcy5oCisrKyBiL2RyaXZlcnMvbmV0L3N0bW1hYy9kZXNjcy5oCkBAIC0yNSwzMyArMjUsMzQg
QEAgc3RydWN0IGRtYV9kZXNjIHsKIAl1bmlvbiB7CiAJCXN0cnVjdCB7CiAJCQkvKiBSREVTMCAq
LwotCQkJdTMyIHJlc2VydmVkMToxOworCQkJdTMyIHBheWxvYWRfY3N1bV9lcnJvcjoxOwogCQkJ
dTMyIGNyY19lcnJvcjoxOwogCQkJdTMyIGRyaWJibGluZzoxOwogCQkJdTMyIG1paV9lcnJvcjox
OwogCQkJdTMyIHJlY2VpdmVfd2F0Y2hkb2c6MTsKIAkJCXUzMiBmcmFtZV90eXBlOjE7CiAJCQl1
MzIgY29sbGlzaW9uOjE7Ci0JCQl1MzIgZnJhbWVfdG9vX2xvbmc6MTsKKwkJCXUzMiBpcGNfY3N1
bV9lcnJvcjoxOwogCQkJdTMyIGxhc3RfZGVzY3JpcHRvcjoxOwogCQkJdTMyIGZpcnN0X2Rlc2Ny
aXB0b3I6MTsKLQkJCXUzMiBtdWx0aWNhc3RfZnJhbWU6MTsKLQkJCXUzMiBydW5fZnJhbWU6MTsK
KwkJCXUzMiB2bGFuX3RhZzoxOworCQkJdTMyIG92ZXJmbG93X2Vycm9yOjE7CiAJCQl1MzIgbGVu
Z3RoX2Vycm9yOjE7Ci0JCQl1MzIgcGFydGlhbF9mcmFtZV9lcnJvcjoxOworCQkJdTMyIHNhX2Zp
bHRlcl9mYWlsOjE7CiAJCQl1MzIgZGVzY3JpcHRvcl9lcnJvcjoxOwogCQkJdTMyIGVycm9yX3N1
bW1hcnk6MTsKIAkJCXUzMiBmcmFtZV9sZW5ndGg6MTQ7Ci0JCQl1MzIgZmlsdGVyaW5nX2ZhaWw6
MTsKKwkJCXUzMiBkYV9maWx0ZXJfZmFpbDoxOwogCQkJdTMyIG93bjoxOwogCQkJLyogUkRFUzEg
Ki8KIAkJCXUzMiBidWZmZXIxX3NpemU6MTE7CiAJCQl1MzIgYnVmZmVyMl9zaXplOjExOwotCQkJ
dTMyIHJlc2VydmVkMjoyOworCQkJdTMyIHJlc2VydmVkMToyOwogCQkJdTMyIHNlY29uZF9hZGRy
ZXNzX2NoYWluZWQ6MTsKIAkJCXUzMiBlbmRfcmluZzoxOwotCQkJdTMyIHJlc2VydmVkMzo1Owor
CQkJdTMyIHJlc2VydmVkMjo1OwogCQkJdTMyIGRpc2FibGVfaWM6MTsKKwogCQl9IHJ4OwogCQlz
dHJ1Y3QgewogCQkJLyogUkRFUzAgKi8KQEAgLTkxLDI0ICs5MiwyOCBAQCBzdHJ1Y3QgZG1hX2Rl
c2MgewogCQkJdTMyIHVuZGVyZmxvd19lcnJvcjoxOwogCQkJdTMyIGV4Y2Vzc2l2ZV9kZWZlcnJh
bDoxOwogCQkJdTMyIGNvbGxpc2lvbl9jb3VudDo0OwotCQkJdTMyIGhlYXJ0YmVhdF9mYWlsOjE7
CisJCQl1MzIgdmxhbl9mcmFtZToxOwogCQkJdTMyIGV4Y2Vzc2l2ZV9jb2xsaXNpb25zOjE7CiAJ
CQl1MzIgbGF0ZV9jb2xsaXNpb246MTsKIAkJCXUzMiBub19jYXJyaWVyOjE7CiAJCQl1MzIgbG9z
c19jYXJyaWVyOjE7Ci0JCQl1MzIgcmVzZXJ2ZWQxOjM7CisJCQl1MzIgcGF5bG9hZF9lcnJvcjox
OworCQkJdTMyIGZyYW1lX2ZsdXNoZWQ6MTsKKwkJCXUzMiBqYWJiZXJfdGltZW91dDoxOwogCQkJ
dTMyIGVycm9yX3N1bW1hcnk6MTsKLQkJCXUzMiByZXNlcnZlZDI6MTU7CisJCQl1MzIgaXBfaGVh
ZGVyX2Vycm9yOjE7CisJCQl1MzIgdGltZV9zdGFtcF9zdGF0dXM6MTsKKwkJCXUzMiByZXNlcnZl
ZDE6MTM7CiAJCQl1MzIgb3duOjE7CiAJCQkvKiBUREVTMSAqLwogCQkJdTMyIGJ1ZmZlcjFfc2l6
ZToxMTsKIAkJCXUzMiBidWZmZXIyX3NpemU6MTE7Ci0JCQl1MzIgcmVzZXJ2ZWQzOjE7CisJCQl1
MzIgdGltZV9zdGFtcF9lbmFibGU6MTsKIAkJCXUzMiBkaXNhYmxlX3BhZGRpbmc6MTsKIAkJCXUz
MiBzZWNvbmRfYWRkcmVzc19jaGFpbmVkOjE7CiAJCQl1MzIgZW5kX3Jpbmc6MTsKIAkJCXUzMiBj
cmNfZGlzYWJsZToxOwotCQkJdTMyIHJlc2VydmVkNDoyOworCQkJdTMyIGNoZWNrc3VtX2luc2Vy
dGlvbjoyOwogCQkJdTMyIGZpcnN0X3NlZ21lbnQ6MTsKIAkJCXUzMiBsYXN0X3NlZ21lbnQ6MTsK
IAkJCXUzMiBpbnRlcnJ1cHQ6MTsKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N0bW1hYy9ub3Jt
X2Rlc2MuYyBiL2RyaXZlcnMvbmV0L3N0bW1hYy9ub3JtX2Rlc2MuYwppbmRleCA3MDA4YzI5Li5m
YWI4ZjBjIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9zdG1tYWMvbm9ybV9kZXNjLmMKKysrIGIv
ZHJpdmVycy9uZXQvc3RtbWFjL25vcm1fZGVzYy5jCkBAIC00OSwxMSArNDksMTIgQEAgc3RhdGlj
IGludCBuZGVzY19nZXRfdHhfc3RhdHVzKHZvaWQgKmRhdGEsIHN0cnVjdCBzdG1tYWNfZXh0cmFf
c3RhdHMgKngsCiAJCQlzdGF0cy0+Y29sbGlzaW9ucyArPSBwLT5kZXMwMS50eC5jb2xsaXNpb25f
Y291bnQ7CiAJCXJldCA9IC0xOwogCX0KLQlpZiAodW5saWtlbHkocC0+ZGVzMDEudHguaGVhcnRi
ZWF0X2ZhaWwpKSB7Ci0JCXgtPnR4X2hlYXJ0YmVhdCsrOwotCQlzdGF0cy0+dHhfaGVhcnRiZWF0
X2Vycm9ycysrOwotCQlyZXQgPSAtMTsKLQl9CisKKyAgICAgICAgaWYgKHAtPmRlczAxLmV0eC52
bGFuX2ZyYW1lKSB7CisgICAgICAgICAgICAgICAgQ0hJUF9EQkcoS0VSTl9JTkZPICJHTUFDIFRY
IHN0YXR1czogVkxBTiBmcmFtZVxuIik7CisgICAgICAgICAgICAgICAgeC0+dHhfdmxhbisrOwor
ICAgICAgICB9CisKIAlpZiAodW5saWtlbHkocC0+ZGVzMDEudHguZGVmZXJyZWQpKQogCQl4LT50
eF9kZWZlcnJlZCsrOwogCkBAIC02NiwxMyArNjcsMTEgQEAgc3RhdGljIGludCBuZGVzY19nZXRf
dHhfbGVuKHN0cnVjdCBkbWFfZGVzYyAqcCkKIH0KIAogLyogVGhpcyBmdW5jdGlvbiB2ZXJpZmll
cyBpZiBlYWNoIGluY29taW5nIGZyYW1lIGhhcyBzb21lIGVycm9ycwotICogYW5kLCBpZiByZXF1
aXJlZCwgdXBkYXRlcyB0aGUgbXVsdGljYXN0IHN0YXRpc3RpY3MuCi0gKiBJbiBjYXNlIG9mIHN1
Y2Nlc3MsIGl0IHJldHVybnMgY3N1bV9ub25lIGJlY2F1c2UgdGhlIGRldmljZQotICogaXMgbm90
IGFibGUgdG8gY29tcHV0ZSB0aGUgY3N1bSBpbiBIVy4gKi8KKyAqIGFuZCwgaWYgcmVxdWlyZWQs
IHVwZGF0ZXMgdGhlIG11bHRpY2FzdCBzdGF0aXN0aWNzLiAqLwogc3RhdGljIGludCBuZGVzY19n
ZXRfcnhfc3RhdHVzKHZvaWQgKmRhdGEsIHN0cnVjdCBzdG1tYWNfZXh0cmFfc3RhdHMgKngsCiAJ
CQkgICAgICAgc3RydWN0IGRtYV9kZXNjICpwKQogewotCWludCByZXQgPSBjc3VtX25vbmU7CisJ
aW50IHJldCA9IGdvb2RfZnJhbWU7CiAJc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKnN0YXRzID0g
KHN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICopZGF0YTsKIAogCWlmICh1bmxpa2VseShwLT5kZXMw
MS5yeC5sYXN0X2Rlc2NyaXB0b3IgPT0gMCkpIHsKQEAgLTg1LDEyICs4NCwxMiBAQCBzdGF0aWMg
aW50IG5kZXNjX2dldF9yeF9zdGF0dXModm9pZCAqZGF0YSwgc3RydWN0IHN0bW1hY19leHRyYV9z
dGF0cyAqeCwKIAlpZiAodW5saWtlbHkocC0+ZGVzMDEucnguZXJyb3Jfc3VtbWFyeSkpIHsKIAkJ
aWYgKHVubGlrZWx5KHAtPmRlczAxLnJ4LmRlc2NyaXB0b3JfZXJyb3IpKQogCQkJeC0+cnhfZGVz
YysrOwotCQlpZiAodW5saWtlbHkocC0+ZGVzMDEucngucGFydGlhbF9mcmFtZV9lcnJvcikpCi0J
CQl4LT5yeF9wYXJ0aWFsKys7Ci0JCWlmICh1bmxpa2VseShwLT5kZXMwMS5yeC5ydW5fZnJhbWUp
KQotCQkJeC0+cnhfcnVudCsrOwotCQlpZiAodW5saWtlbHkocC0+ZGVzMDEucnguZnJhbWVfdG9v
X2xvbmcpKQotCQkJeC0+cnhfdG9vbG9uZysrOworCQlpZiAodW5saWtlbHkocC0+ZGVzMDEucngu
c2FfZmlsdGVyX2ZhaWwpKQorCQkJeC0+c2FfZmlsdGVyX2ZhaWwrKzsKKwkJaWYgKHVubGlrZWx5
KHAtPmRlczAxLnJ4Lm92ZXJmbG93X2Vycm9yKSkKKwkJCXgtPm92ZXJmbG93X2Vycm9yKys7CisJ
CWlmICh1bmxpa2VseShwLT5kZXMwMS5yeC5pcGNfY3N1bV9lcnJvcikpCisJCQl4LT5pcGNfY3N1
bV9lcnJvcisrOwogCQlpZiAodW5saWtlbHkocC0+ZGVzMDEucnguY29sbGlzaW9uKSkgewogCQkJ
eC0+cnhfY29sbGlzaW9uKys7CiAJCQlzdGF0cy0+Y29sbGlzaW9ucysrOwpAQCAtMTEyLDEwICsx
MTEsMTIgQEAgc3RhdGljIGludCBuZGVzY19nZXRfcnhfc3RhdHVzKHZvaWQgKmRhdGEsIHN0cnVj
dCBzdG1tYWNfZXh0cmFfc3RhdHMgKngsCiAJCXgtPnJ4X21paSsrOwogCQlyZXQgPSBkaXNjYXJk
X2ZyYW1lOwogCX0KLQlpZiAocC0+ZGVzMDEucngubXVsdGljYXN0X2ZyYW1lKSB7Ci0JCXgtPnJ4
X211bHRpY2FzdCsrOwotCQlzdGF0cy0+bXVsdGljYXN0Kys7CisjaWZkZWYgU1RNTUFDX1ZMQU5f
VEFHX1VTRUQKKwlpZiAocC0+ZGVzMDEucngudmxhbl90YWcpIHsKKwkJeC0+dmxhbl90YWcrKzsK
KwkJc3RhdHMtPnZsYW5fdGFnKys7CiAJfQorI2VuZGlmCiAJcmV0dXJuIHJldDsKIH0KIApAQCAt
MTg0LDYgKzE4NSw5IEBAIHN0YXRpYyB2b2lkIG5kZXNjX3ByZXBhcmVfdHhfZGVzYyhzdHJ1Y3Qg
ZG1hX2Rlc2MgKnAsIGludCBpc19mcywgaW50IGxlbiwKIHsKIAlwLT5kZXMwMS50eC5maXJzdF9z
ZWdtZW50ID0gaXNfZnM7CiAJbm9ybV9zZXRfdHhfZGVzY19sZW4ocCwgbGVuKTsKKworCWlmIChs
aWtlbHkoY3N1bV9mbGFnKSkKKwkJcC0+ZGVzMDEudHguY2hlY2tzdW1faW5zZXJ0aW9uID0gY2lj
X2Z1bGw7CiB9CiAKIHN0YXRpYyB2b2lkIG5kZXNjX2NsZWFyX3R4X2ljKHN0cnVjdCBkbWFfZGVz
YyAqcCkKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N0bW1hYy9zdG1tYWNfZXRodG9vbC5jIGIv
ZHJpdmVycy9uZXQvc3RtbWFjL3N0bW1hY19ldGh0b29sLmMKaW5kZXggN2VkOGZiNi4uM2Q1OGZj
YyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvc3RtbWFjL3N0bW1hY19ldGh0b29sLmMKKysrIGIv
ZHJpdmVycy9uZXQvc3RtbWFjL3N0bW1hY19ldGh0b29sLmMKQEAgLTUwLDcgKzUwLDcgQEAgc3Rh
dGljIGNvbnN0IHN0cnVjdCAgc3RtbWFjX3N0YXRzIHN0bW1hY19nc3RyaW5nc19zdGF0c1tdID0g
ewogCVNUTU1BQ19TVEFUKHR4X3VuZGVyZmxvdyksCiAJU1RNTUFDX1NUQVQodHhfY2Fycmllciks
CiAJU1RNTUFDX1NUQVQodHhfbG9zc2NhcnJpZXIpLAotCVNUTU1BQ19TVEFUKHR4X2hlYXJ0YmVh
dCksCisJU1RNTUFDX1NUQVQodmxhbl90YWcpLAogCVNUTU1BQ19TVEFUKHR4X2RlZmVycmVkKSwK
IAlTVE1NQUNfU1RBVCh0eF92bGFuKSwKIAlTVE1NQUNfU1RBVChyeF92bGFuKSwKQEAgLTU5LDkg
KzU5LDkgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCAgc3RtbWFjX3N0YXRzIHN0bW1hY19nc3RyaW5n
c19zdGF0c1tdID0gewogCVNUTU1BQ19TVEFUKHR4X3BheWxvYWRfZXJyb3IpLAogCVNUTU1BQ19T
VEFUKHR4X2lwX2hlYWRlcl9lcnJvciksCiAJU1RNTUFDX1NUQVQocnhfZGVzYyksCi0JU1RNTUFD
X1NUQVQocnhfcGFydGlhbCksCi0JU1RNTUFDX1NUQVQocnhfcnVudCksCi0JU1RNTUFDX1NUQVQo
cnhfdG9vbG9uZyksCisJU1RNTUFDX1NUQVQoc2FfZmlsdGVyX2ZhaWwpLAorCVNUTU1BQ19TVEFU
KG92ZXJmbG93X2Vycm9yKSwKKwlTVE1NQUNfU1RBVChpcGNfY3N1bV9lcnJvciksCiAJU1RNTUFD
X1NUQVQocnhfY29sbGlzaW9uKSwKIAlTVE1NQUNfU1RBVChyeF9jcmMpLAogCVNUTU1BQ19TVEFU
KHJ4X2xlbmd0aCksCi0tIAoxLjcuMQoK
--20cf30780d00b7076804b02c13c9--
