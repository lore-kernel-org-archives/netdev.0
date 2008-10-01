From: "Rami Rosen" <roszenrami@gmail.com>
Subject: [PATCH 1/2] ipv4: add mc_count to in_device.
Date: Wed, 1 Oct 2008 10:04:48 +0300
Message-ID: <b25312890810010004p15e85df1u69125c7fa47ae01f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_25413_25183016.1222844688826"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	"Pekka Savola" <pekkas@netcore.fi>
To: davem@davemloft.net, "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:9087 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbYJAHEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 03:04:49 -0400
Received: by rv-out-0506.google.com with SMTP id k40so440199rvb.1
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 00:04:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_25413_25183016.1222844688826
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch add mc_count to struct in_device and
updates increment/decrement/initilaize of this field in IPv4 and in IPv6.

- Also printing the vfs /proc entry (/proc/net/igmp) is adjusted to
use the new mc_count.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>



On Wed, Oct 1, 2008 at 9:57 AM, Rami Rosen <roszenrami@gmail.com> wrote:
> Hi,
>    - This patch set adds mc_count to  struct in_device (IPv4) and to
> struct inet6_dev (IPv6) and updates increment/decrement/initialization
> of this field in IPv4 and in IPv6.
>
> - Also printing the /proc entry (/proc/net/igmp) is adjusted to use
> the new mc_count.
>
>  - Thanks to David Stevens for his feedback.
>
> Regards,
> Rami Rosen
>
> On Thu, Sep 25, 2008 at 10:35 AM, David Stevens <dlstevens@us.ibm.com> wrote:
>> netdev-owner@vger.kernel.org wrote on 09/24/2008 11:44:45 PM:
>>
>>> Hi,
>>>
>>> - I had noticed a long ago that the IP addresses under
>>>  /proc/net/igmp are in Hexa format. I am preparing a patch to fix it
>>> and it will be send very soon.
>>
>> I don't think we can do that, since I believe netstat expects
>> to see this the way it is. Maybe if we change netstat to support
>> both and wait a year for all distros to get it... :-)
>>
>>
>>> So indeed , the count (mc_count of netdevice) shows both IPv4 and IPv6
>> igmp
>>> groups, but in current implementation it is not immediate
>>> to change it. Currently, net_device struct does not have specific
>>> fields for ipv4 or ipv6.  One way of preparing a patch
>>> is to change net_device to have mc_count4 and mc_count6;
>>> I am really willing to prepare such a patch, but I am not sure such a
>>> change in net_device is a proper and a justified
>>> change to do.
>>
>>        These belong with mc_list in inet6_dev and in_device. Really,
>> I'd just add "mc_count" as a field right next to mc_list and inc/dec
>> it when calling the group join/leave functions-- use the list lock
>> to protect it. The structure it's in distinguishes the protocol,
>> and the names are otherwise common.
>>
>>                                                                +-DLS
>>
>>
>

------=_Part_25413_25183016.1222844688826
Content-Type: text/plain; name=patch1.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_flrm5b2e0
Content-Disposition: attachment; filename=patch1.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oIGIvaW5jbHVkZS9saW51eC9p
bmV0ZGV2aWNlLmgKaW5kZXggYzZmNTFhZC4uMDZmY2RiNCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9s
aW51eC9pbmV0ZGV2aWNlLmgKKysrIGIvaW5jbHVkZS9saW51eC9pbmV0ZGV2aWNlLmgKQEAgLTI1
LDYgKzI1LDcgQEAgc3RydWN0IGluX2RldmljZQogCXN0cnVjdCBpbl9pZmFkZHIJKmlmYV9saXN0
OwkvKiBJUCBpZmFkZHIgY2hhaW4JCSovCiAJcndsb2NrX3QJCW1jX2xpc3RfbG9jazsKIAlzdHJ1
Y3QgaXBfbWNfbGlzdAkqbWNfbGlzdDsJLyogSVAgbXVsdGljYXN0IGZpbHRlciBjaGFpbiAgICAq
LworCWludAkJCW1jX2NvdW50OwkgICAgICAgICAgLyogTnVtYmVyIG9mIGluc3RhbGxlZCBtY2Fz
dHMJKi8KIAlzcGlubG9ja190CQltY190b21iX2xvY2s7CiAJc3RydWN0IGlwX21jX2xpc3QJKm1j
X3RvbWI7CiAJdW5zaWduZWQgbG9uZwkJbXJfdjFfc2VlbjsKZGlmZiAtLWdpdCBhL25ldC9pcHY0
L2lnbXAuYyBiL25ldC9pcHY0L2lnbXAuYwppbmRleCBmNzBmYWM2Li43ZjllMzM3IDEwMDY0NAot
LS0gYS9uZXQvaXB2NC9pZ21wLmMKKysrIGIvbmV0L2lwdjQvaWdtcC5jCkBAIC0xMjM0LDYgKzEy
MzQsNyBAQCB2b2lkIGlwX21jX2luY19ncm91cChzdHJ1Y3QgaW5fZGV2aWNlICppbl9kZXYsIF9f
YmUzMiBhZGRyKQogCXdyaXRlX2xvY2tfYmgoJmluX2Rldi0+bWNfbGlzdF9sb2NrKTsKIAlpbS0+
bmV4dD1pbl9kZXYtPm1jX2xpc3Q7CiAJaW5fZGV2LT5tY19saXN0PWltOworCWluX2Rldi0+bWNf
Y291bnQrKzsKIAl3cml0ZV91bmxvY2tfYmgoJmluX2Rldi0+bWNfbGlzdF9sb2NrKTsKICNpZmRl
ZiBDT05GSUdfSVBfTVVMVElDQVNUCiAJaWdtcHYzX2RlbF9kZWxyZWMoaW5fZGV2LCBpbS0+bXVs
dGlhZGRyKTsKQEAgLTEyODIsNiArMTI4Myw3IEBAIHZvaWQgaXBfbWNfZGVjX2dyb3VwKHN0cnVj
dCBpbl9kZXZpY2UgKmluX2RldiwgX19iZTMyIGFkZHIpCiAJCQlpZiAoLS1pLT51c2VycyA9PSAw
KSB7CiAJCQkJd3JpdGVfbG9ja19iaCgmaW5fZGV2LT5tY19saXN0X2xvY2spOwogCQkJCSppcCA9
IGktPm5leHQ7CisJCQkJaW5fZGV2LT5tY19jb3VudC0tOwogCQkJCXdyaXRlX3VubG9ja19iaCgm
aW5fZGV2LT5tY19saXN0X2xvY2spOwogCQkJCWlnbXBfZ3JvdXBfZHJvcHBlZChpKTsKIApAQCAt
MTMzMCw2ICsxMzMyLDcgQEAgdm9pZCBpcF9tY19pbml0X2RldihzdHJ1Y3QgaW5fZGV2aWNlICpp
bl9kZXYpCiAJc2V0dXBfdGltZXIoJmluX2Rldi0+bXJfZ3FfdGltZXIsIGlnbXBfZ3FfdGltZXJf
ZXhwaXJlLAogCQkJKHVuc2lnbmVkIGxvbmcpaW5fZGV2KTsKIAlpbl9kZXYtPm1yX2lmY19jb3Vu
dCA9IDA7CisJaW5fZGV2LT5tY19jb3VudCAgICAgPSAwOwogCXNldHVwX3RpbWVyKCZpbl9kZXYt
Pm1yX2lmY190aW1lciwgaWdtcF9pZmNfdGltZXJfZXhwaXJlLAogCQkJKHVuc2lnbmVkIGxvbmcp
aW5fZGV2KTsKIAlpbl9kZXYtPm1yX3FydiA9IElHTVBfVW5zb2xpY2l0ZWRfUmVwb3J0X0NvdW50
OwpAQCAtMTM2OSw4ICsxMzcyLDggQEAgdm9pZCBpcF9tY19kZXN0cm95X2RldihzdHJ1Y3QgaW5f
ZGV2aWNlICppbl9kZXYpCiAJd3JpdGVfbG9ja19iaCgmaW5fZGV2LT5tY19saXN0X2xvY2spOwog
CXdoaWxlICgoaSA9IGluX2Rldi0+bWNfbGlzdCkgIT0gTlVMTCkgewogCQlpbl9kZXYtPm1jX2xp
c3QgPSBpLT5uZXh0OworCQlpbl9kZXYtPm1jX2NvdW50LS07CiAJCXdyaXRlX3VubG9ja19iaCgm
aW5fZGV2LT5tY19saXN0X2xvY2spOwotCiAJCWlnbXBfZ3JvdXBfZHJvcHBlZChpKTsKIAkJaXBf
bWFfcHV0KGkpOwogCkBAIC0yMzgzLDcgKzIzODYsNyBAQCBzdGF0aWMgaW50IGlnbXBfbWNfc2Vx
X3Nob3coc3RydWN0IHNlcV9maWxlICpzZXEsIHZvaWQgKnYpCiAKIAkJaWYgKHN0YXRlLT5pbl9k
ZXYtPm1jX2xpc3QgPT0gaW0pIHsKIAkJCXNlcV9wcmludGYoc2VxLCAiJWRcdCUtMTBzOiAlNWQg
JTdzXG4iLAotCQkJCSAgIHN0YXRlLT5kZXYtPmlmaW5kZXgsIHN0YXRlLT5kZXYtPm5hbWUsIHN0
YXRlLT5kZXYtPm1jX2NvdW50LCBxdWVyaWVyKTsKKwkJCQkgICBzdGF0ZS0+ZGV2LT5pZmluZGV4
LCBzdGF0ZS0+ZGV2LT5uYW1lLCBzdGF0ZS0+aW5fZGV2LT5tY19jb3VudCwgcXVlcmllcik7CiAJ
CX0KIAogCQlzZXFfcHJpbnRmKHNlcSwK
------=_Part_25413_25183016.1222844688826--
