From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink
 code
Date: Fri, 31 Aug 2007 13:05:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708311258520.8423@x2>
References: <bug-8961-10286@http.bugzilla.kernel.org/>
 <20070830180842.7c8414fe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1104557054-1188558304=:8423"
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	link@miggy.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56028 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750AbXHaLGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 07:06:19 -0400
In-Reply-To: <20070830180842.7c8414fe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1104557054-1188558304=:8423
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Thu, 30 Aug 2007, Andrew Morton wrote:

> On Thu, 30 Aug 2007 07:41:31 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=8961
>
> This looks serious.
>
>>            Summary: BUG triggered by oidentd in netlink code
>>
>> Aug 29 23:28:44 bowl kernel: [349587.500440] BUG: unable to handle kernel NULL
>> pointer dereference<1>BUG: unable to handle kernel NULL pointer dereference at
>> virtual address 00000054
>> Aug 29 23:28:44 bowl kernel: [349587.500454]  printing eip:
>> Aug 29 23:28:45 bowl kernel: [349587.500457] c03318ae
>> Aug 29 23:28:45 bowl kernel: [349587.500459] *pde = 00000000
>> Aug 29 23:28:45 bowl kernel: [349587.500464] Oops: 0000 [#1]
>> Aug 29 23:28:45 bowl kernel: [349587.500466] PREEMPT SMP
>> Aug 29 23:28:46 bowl kernel: [349587.500474] Modules linked in: w83627hf
>> hwmon_vid i2c_isa
>> Aug 29 23:28:46 bowl kernel: [349587.500483] CPU:    0
>> Aug 29 23:28:47 bowl kernel: [349587.500485] EIP:    0060:[<c03318ae>]    Not
>> tainted VLI
>> Aug 29 23:28:47 bowl kernel: [349587.500487] EFLAGS: 00010246   (2.6.22.3 #1)
>> Aug 29 23:28:47 bowl kernel: [349587.500499] EIP is at netlink_rcv_skb+0xa/0x7e
>> Aug 29 23:28:48 bowl kernel: [349587.500506] eax: 00000000   ebx: 00000000


Seems to be a bug introduced by the netlink_run_queue conversion,
since there is no locking and netlink_run_queue doesn't check
for NULL results from skb_dequeue, it might pass NULL to
netlink_rcv_skb, which crashes.

Does this patch help?
--8323328-1104557054-1188558304=:8423
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=x
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0708311305040.8423@x2>
Content-Description: 
Content-Disposition: attachment; filename=x

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2luZXRfZGlhZy5jIGIvbmV0L2lwdjQv
aW5ldF9kaWFnLmMNCmluZGV4IGRiZWFjZDguLjhlMTA3OGQgMTAwNjQ0DQot
LS0gYS9uZXQvaXB2NC9pbmV0X2RpYWcuYw0KKysrIGIvbmV0L2lwdjQvaW5l
dF9kaWFnLmMNCkBAIC04MzYsMTIgKzgzNiwxNyBAQCBzdGF0aWMgaW50IGlu
ZXRfZGlhZ19yY3ZfbXNnKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBu
bG1zZ2hkciAqbmxoKQ0KIAlyZXR1cm4gaW5ldF9kaWFnX2dldF9leGFjdChz
a2IsIG5saCk7DQogfQ0KIA0KK3N0YXRpYyBERUZJTkVfTVVURVgoaW5ldF9k
aWFnX211dGV4KTsNCisNCiBzdGF0aWMgdm9pZCBpbmV0X2RpYWdfcmN2KHN0
cnVjdCBzb2NrICpzaywgaW50IGxlbikNCiB7DQogCXVuc2lnbmVkIGludCBx
bGVuID0gMDsNCiANCiAJZG8gew0KKwkJaWYgKCFtdXRleF90cnlsb2NrKCZp
bmV0X2RpYWdfbXV0ZXgpKQ0KKwkJCXJldHVybjsNCiAJCW5ldGxpbmtfcnVu
X3F1ZXVlKHNrLCAmcWxlbiwgJmluZXRfZGlhZ19yY3ZfbXNnKTsNCisJCW11
dGV4X3VubG9jaygmaW5ldF9kaWFnX211dGV4KTsNCiAJfSB3aGlsZSAocWxl
bik7DQogfQ0KIA0K

--8323328-1104557054-1188558304=:8423--
