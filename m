From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: [PATCH 2/2] ipv6: add mc_count to inet6_dev
Date: Wed, 1 Oct 2008 10:09:07 +0300
Message-ID: <b25312890810010009p73ebdfci88608455a3075c18@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_25445_5568742.1222844947942"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	"Pekka Savola" <pekkas@netcore.fi>
To: davem@davemloft.net, "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:3159 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbYJAHJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 03:09:08 -0400
Received: by wf-out-1314.google.com with SMTP id 27so432873wfd.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 00:09:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_25445_5568742.1222844947942
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patch adds mc_count to struct inet6_dev
and updates increment/decrement/initilaize of this field.

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

------=_Part_25445_5568742.1222844947942
Content-Type: text/plain; name=patch2.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_flrm9nw50
Content-Disposition: attachment; filename=patch2.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lmX2luZXQ2LmggYi9pbmNsdWRlL25ldC9pZl9pbmV0
Ni5oCmluZGV4IGM4ZWZmYTQuLjllOTEzOWMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lmX2lu
ZXQ2LmgKKysrIGIvaW5jbHVkZS9uZXQvaWZfaW5ldDYuaApAQCAtMTYzLDYgKzE2Myw3IEBAIHN0
cnVjdCBpbmV0Nl9kZXYKIAlzdHJ1Y3QgaW5ldDZfaWZhZGRyCSphZGRyX2xpc3Q7CiAKIAlzdHJ1
Y3QgaWZtY2FkZHI2CSptY19saXN0OworCWludAkJCW1jX2NvdW50OwkgICAgICAgICAgLyogTnVt
YmVyIG9mIGluc3RhbGxlZCBtY2FzdHMJKi8KIAlzdHJ1Y3QgaWZtY2FkZHI2CSptY190b21iOwog
CXJ3bG9ja190CQltY19sb2NrOwogCXVuc2lnbmVkIGNoYXIJCW1jX3FydjsKZGlmZiAtLWdpdCBh
L25ldC9pcHY2L21jYXN0LmMgYi9uZXQvaXB2Ni9tY2FzdC5jCmluZGV4IGU3YzAzYmMuLjgzNTUy
MWQgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L21jYXN0LmMKKysrIGIvbmV0L2lwdjYvbWNhc3QuYwpA
QCAtOTIyLDYgKzkyMiw3IEBAIGludCBpcHY2X2Rldl9tY19pbmMoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldiwgY29uc3Qgc3RydWN0IGluNl9hZGRyICphZGRyKQogCiAJbWMtPm5leHQgPSBpZGV2LT5t
Y19saXN0OwogCWlkZXYtPm1jX2xpc3QgPSBtYzsKKwltYy0+aWRldi0+bWNfY291bnQrKzsKIAl3
cml0ZV91bmxvY2tfYmgoJmlkZXYtPmxvY2spOwogCiAJbWxkX2RlbF9kZWxyZWMoaWRldiwgJm1j
LT5tY2FfYWRkcik7CkBAIC05NDMsNyArOTQ0LDcgQEAgaW50IF9faXB2Nl9kZXZfbWNfZGVjKHN0
cnVjdCBpbmV0Nl9kZXYgKmlkZXYsIGNvbnN0IHN0cnVjdCBpbjZfYWRkciAqYWRkcikKIAkJCWlm
ICgtLW1hLT5tY2FfdXNlcnMgPT0gMCkgewogCQkJCSptYXAgPSBtYS0+bmV4dDsKIAkJCQl3cml0
ZV91bmxvY2tfYmgoJmlkZXYtPmxvY2spOwotCisJCQkJaWRldi0+bWNfY291bnQtLTsKIAkJCQlp
Z21wNl9ncm91cF9kcm9wcGVkKG1hKTsKIAogCQkJCW1hX3B1dChtYSk7CkBAIC0yMjg4LDYgKzIy
ODksNyBAQCB2b2lkIGlwdjZfbWNfaW5pdF9kZXYoc3RydWN0IGluZXQ2X2RldiAqaWRldikKIAkJ
CSh1bnNpZ25lZCBsb25nKWlkZXYpOwogCWlkZXYtPm1jX3RvbWIgPSBOVUxMOwogCWlkZXYtPm1j
X2lmY19jb3VudCA9IDA7CisJaWRldi0+bWNfY291bnQ9MDsKIAlzZXR1cF90aW1lcigmaWRldi0+
bWNfaWZjX3RpbWVyLCBtbGRfaWZjX3RpbWVyX2V4cGlyZSwKIAkJCSh1bnNpZ25lZCBsb25nKWlk
ZXYpOwogCWlkZXYtPm1jX3FydiA9IE1MRF9RUlZfREVGQVVMVDsK
------=_Part_25445_5568742.1222844947942--
