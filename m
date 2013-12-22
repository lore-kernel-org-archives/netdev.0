From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Sun, 22 Dec 2013 11:15:32 -0500
Message-ID: <52B71024.3090504@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com>	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>	<52B1FC6D.7040005@mojatatu.com> <CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050308000400010302080405"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:43542 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab3LVQPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 11:15:36 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so5104196ief.20
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 08:15:35 -0800 (PST)
In-Reply-To: <CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050308000400010302080405
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



I am sorry Cong - I will still object to this change. I dont want
to even bother testing it.
You are making some serious policy decisions in the kernel.
Such policy decisions should be made by user space not the kernel.
Whoever made the idiotic decision of removing the device should
modify or delete the flow rule - at minimal they
may deserve some warning. Deleting the action is wrong. It is simple
graph theory.
Slightly related is this - look at the attached test (I went out of
my way to annotate it) and imagine you have mirred where the policers
are ....

cheers,
jamal

On 12/18/13 16:42, Cong Wang wrote:
> On Wed, Dec 18, 2013 at 11:50 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 12/18/13 13:36, Cong Wang wrote:
>>>
>>> On Wed, Dec 18, 2013 at 6:31 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>>> wrote:
>>>>
>>>> On 12/15/13 23:15, Cong Wang wrote:
>>>>>
>>>>>
>>>>> When the target device is removed, the mirred action is
>>>>> still there but with the dev pointer setting to NULL.
>>>>> This makes the output from 'tc filter' ugly. There is no
>>>>> reason to keep it.
>>>>>
>>>>
>>>> Sorry - this one i have problems with.
>>>> actions may be referenced from multiple filters,
>>>> you cant just delete it (that would leave other users
>>>> pointing to it dangling). Destroying would eventually
>>>> delete it when the refcount goes to 0.
>>>
>>>
>>> How? tcf_action_init() always allocates a new action,
>>> it doesn't even look for an existing one.
>>>
>>
>>
>> tc action blah index 123
>> tc action filter goo action blah index 123
>> tc action filter gah action blah index 123
>>
>> Very useful for example for multiple flows to
>> share the same policer.
>>
>
> Ah, I see. I will create a test case for this
> and rework on the mirred patch.
>


--------------050308000400010302080405
Content-Type: text/plain; charset=us-ascii;
 name="shared-act-tst1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="shared-act-tst1"

VEM9Ii9zYmluL3RjIgojCnN1ZG8gaWZjb25maWcgZHVtbXkwIHVwCnN1ZG8gaWZjb25maWcg
ZHVtbXkxIHVwCkRFVjE9ImV0aDAiCkRFVjI9ImV0aDEiCiMKIwojCnN1ZG8gJFRDIHFkaXNj
IGRlbCBkZXYgJERFVjEgaW5ncmVzcwpzdWRvICRUQyBxZGlzYyBhZGQgZGV2ICRERVYxIGlu
Z3Jlc3MKc3VkbyAkVEMgcWRpc2MgZGVsIGRldiAkREVWMiBpbmdyZXNzCnN1ZG8gJFRDIHFk
aXNjIGFkZCBkZXYgJERFVjIgaW5ncmVzcwojTm90ZSAtIG9sZGVyIHRjIGRpZCBub3QgcGlw
ZSBmb3Igc2tiZWRpdCAoYWRkICJwaXBlIiBpZiB0aGlzIGlzIHJlamVjdGVkKQpzdWRvICRU
QyBmaWx0ZXIgYWRkIGRldiAkREVWMSBwYXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgcHJlZiAx
MCBcCnUzMiBtYXRjaCBpcCBwcm90b2NvbCAxIDB4ZmYgZmxvd2lkIDE6MTAgXAphY3Rpb24g
c2tiZWRpdCBtYXJrIDExIFwKYWN0aW9uIHBvbGljZSByYXRlIDEwa2JpdCBidXJzdCAxMGsg
cGlwZSBpbmRleCAxIFwKYWN0aW9uIHNrYmVkaXQgbWFyayAxMiBcCmFjdGlvbiBwb2xpY2Ug
cmF0ZSAyMGtiaXQgYnVyc3QgMjBrIHBpcGUgaW5kZXggMiBcCmFjdGlvbiBhY3Rpb24gbWly
cmVkIGVncmVzcyBtaXJyb3IgZGV2IGR1bW15MAojbm90ZSBzaGFyaW5nIG9mIHRoZSB0d28g
cG9saWNlcnMgYnkgdHdvIGZsb3dzCiNhY3Jvc3MgbXVsdGlwbGUgZGV2aWNlcwpzdWRvICRU
QyBmaWx0ZXIgYWRkIGRldiAkREVWMiBwYXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgcHJlZiAx
MCBcCnUzMiBtYXRjaCBpcCBwcm90b2NvbCAxIDB4ZmYgZmxvd2lkIDE6MTAgXAphY3Rpb24g
c2tiZWRpdCBtYXJrIDIxIFwKYWN0aW9uIHBvbGljZSByYXRlIDEwa2JpdCBidXJzdCAxMGsg
cGlwZSBpbmRleCAxIFwKYWN0aW9uIHNrYmVkaXQgbWFyayAyMiBcCmFjdGlvbiBwb2xpY2Ug
cmF0ZSAyMGtiaXQgYnVyc3QgMjBrIHBpcGUgaW5kZXggMiBcCmFjdGlvbiBhY3Rpb24gbWly
cmVkIGVncmVzcyBtaXJyb3IgZGV2IGR1bW15MQojCiMKIyBub3cgZG8gYSBwaW5nIC1mIHRv
IHNvbWV3aGVyZSwgZm9yIG1vcmUgZXhjaXRpbmcgcmVzdWx0cwojIGRvIGEgLXMgMjA0OCBv
ciBzbwojIHN1ZG8gcGluZyAtZiAxOTIuMTY4LjEuMTAwIC1jIDEwMDAwCiMgc3VkbyBwaW5n
IC1mIDEyNy4wLjAuMSAtYyAxMDAwMAojCnN1ZG8gdGMgLXMgZmlsdGVyIGxzIGRldiAkREVW
MSBwYXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgCnN1ZG8gdGMgLXMgZmlsdGVyIGxzIGRldiAk
REVWMiBwYXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgCnN1ZG8gdGMgLXMgYWN0aW9ucyBscyBh
Y3Rpb24gcG9saWNlCnN1ZG8gdGMgLXMgYWN0aW9ucyBscyBhY3Rpb24gc2tiZWRpdAo=
--------------050308000400010302080405--
