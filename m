From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco
 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Fri, 25 Oct 2013 08:25:57 -0700
Message-ID: <CALnjE+pdvpfCTo=bTtSrY29mxc0yZKMj0XSc2gQVhGjbpByhcA@mail.gmail.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
	<1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
	<1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>
	<1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>
	<1382096356.63655.YahooMailNeo@web172002.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6dc224fb083c04e9925df5
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter Schmitt <peter.schmitt82@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:49187 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752086Ab3JYPZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 11:25:58 -0400
Received: by mail-vb0-f46.google.com with SMTP id 10so2580409vbe.33
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 08:25:58 -0700 (PDT)
In-Reply-To: <1382096356.63655.YahooMailNeo@web172002.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6dc224fb083c04e9925df5
Content-Type: text/plain; charset=ISO-8859-1

Hi Peter,
I think its easy to fix this case, Can you try attached patch?
If it works I will send formal patch for stable.

Thanks,
Pravin.

On Fri, Oct 18, 2013 at 4:39 AM, Peter Schmitt <peter.schmitt82@yahoo.de> wrote:
> Hi,
>
>
>
>> On Thursday, October 17, 2013 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2013-10-17 at 11:53 +0100, Peter Schmitt wrote:
>>>  Hi,
>>>
>>>
>>>  >
>>>  > 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the probable
>>>  > fix :
>>>  >
>>>  > commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
>>>  > ("ip_tunnel: push generic protocol handling to ip_tunnel
>> module.")
>>>  >
>>>  > The problem is 3.10 do not pull the extra 4 bytes of WCCP
>>>  >
>>>  > This is now properly done in iptunnel_pull_header()
>>>  >
>>>
>>>  First of all, many thanks for your help on this.
>>>
>>>  I tried to apply the fix to the 3.10.16 sources, as I would like to
>>>  stay with the long-term line. Unfortunately it does not apply, as
>>>  there are a lot of dependencies on other patches.
>>>
>>>  Do you think there will be a fix for the long-time 3.10 kernel line?
>>>  Or can you guide me on how to apply this fix to the long-term kernel?
>>
>> 3.10 is right in the middle of GRE refactoring, and many bugs are in it.
>>
>> It might be very painful to get a complete list of patches to backport.
>
> thanks again. Yes I saw that there were lots of changes.
>
> Do you think there will be a fix for all the 3.10.x stable long term kernel users? Many of them might not be able to use some newer kernel easily or will this be a "won't fix"?
>
> Best regards,
> Peter
>

--047d7b6dc224fb083c04e9925df5
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-ip_gre-Fix-WCCPv2-header-parsing.patch"
Content-Disposition: attachment;
	filename="0001-ip_gre-Fix-WCCPv2-header-parsing.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hn7kre8v0

RnJvbSA2MGUwMTQ4ZjQyNGE4YmVlOTg3ZjhjNjA2YzRhYzIzY2JlNzBhNTY3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQcmF2aW4gQiBTaGVsYXIgPHBzaGVsYXJAbmljaXJhLmNvbT4K
RGF0ZTogRnJpLCAyNSBPY3QgMjAxMyAwODoxOTo1OSAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIGlw
X2dyZTogRml4IFdDQ1B2MiBoZWFkZXIgcGFyc2luZy4KClB1bGwgY3VycmVjdCBoZWFkZXItbGVu
IGZvciBncmUgcGFja2V0LgotLS0KIGluY2x1ZGUvbmV0L2lwX3R1bm5lbHMuaCB8ICAgIDIgKy0K
IG5ldC9pcHY0L2lwX2dyZS5jICAgICAgICB8ICAgIDIgKy0KIG5ldC9pcHY0L2lwX3R1bm5lbC5j
ICAgICB8ICAgIDQgKystLQogbmV0L2lwdjQvaXBpcC5jICAgICAgICAgIHwgICAgMiArLQogNCBm
aWxlcyBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvaW5jbHVkZS9uZXQvaXBfdHVubmVscy5oIGIvaW5jbHVkZS9uZXQvaXBfdHVubmVscy5oCmlu
ZGV4IDA5YjEzNjAuLjc5Y2Y5NTggMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lwX3R1bm5lbHMu
aAorKysgYi9pbmNsdWRlL25ldC9pcF90dW5uZWxzLmgKQEAgLTExMyw3ICsxMTMsNyBAQCBzdHJ1
Y3QgaXBfdHVubmVsICppcF90dW5uZWxfbG9va3VwKHN0cnVjdCBpcF90dW5uZWxfbmV0ICppdG4s
CiAJCQkJICAgX19iZTMyIGtleSk7CiAKIGludCBpcF90dW5uZWxfcmN2KHN0cnVjdCBpcF90dW5u
ZWwgKnR1bm5lbCwgc3RydWN0IHNrX2J1ZmYgKnNrYiwKLQkJICBjb25zdCBzdHJ1Y3QgdG5sX3B0
a19pbmZvICp0cGksIGJvb2wgbG9nX2Vjbl9lcnJvcik7CisJCSAgY29uc3Qgc3RydWN0IHRubF9w
dGtfaW5mbyAqdHBpLCBpbnQgaGRyX2xlbiwgYm9vbCBsb2dfZWNuX2Vycm9yKTsKIGludCBpcF90
dW5uZWxfY2hhbmdlbGluayhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgbmxhdHRyICp0
YltdLAogCQkJIHN0cnVjdCBpcF90dW5uZWxfcGFybSAqcCk7CiBpbnQgaXBfdHVubmVsX25ld2xp
bmsoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IG5sYXR0ciAqdGJbXSwKZGlmZiAtLWdp
dCBhL25ldC9pcHY0L2lwX2dyZS5jIGIvbmV0L2lwdjQvaXBfZ3JlLmMKaW5kZXggODU1MDA0Zi4u
M2RkYzhkZiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvaXBfZ3JlLmMKKysrIGIvbmV0L2lwdjQvaXBf
Z3JlLmMKQEAgLTMzNSw3ICszMzUsNyBAQCBzdGF0aWMgaW50IGlwZ3JlX3JjdihzdHJ1Y3Qgc2tf
YnVmZiAqc2tiKQogCQkJCSAgaXBoLT5zYWRkciwgaXBoLT5kYWRkciwgdHBpLmtleSk7CiAKIAlp
ZiAodHVubmVsKSB7Ci0JCWlwX3R1bm5lbF9yY3YodHVubmVsLCBza2IsICZ0cGksIGxvZ19lY25f
ZXJyb3IpOworCQlpcF90dW5uZWxfcmN2KHR1bm5lbCwgc2tiLCAmdHBpLCBoZHJfbGVuLCBsb2df
ZWNuX2Vycm9yKTsKIAkJcmV0dXJuIDA7CiAJfQogCWljbXBfc2VuZChza2IsIElDTVBfREVTVF9V
TlJFQUNILCBJQ01QX1BPUlRfVU5SRUFDSCwgMCk7CmRpZmYgLS1naXQgYS9uZXQvaXB2NC9pcF90
dW5uZWwuYyBiL25ldC9pcHY0L2lwX3R1bm5lbC5jCmluZGV4IGNiZmMzN2YuLjQ5ZmI2MDggMTAw
NjQ0Ci0tLSBhL25ldC9pcHY0L2lwX3R1bm5lbC5jCisrKyBiL25ldC9pcHY0L2lwX3R1bm5lbC5j
CkBAIC00MDIsNyArNDAyLDcgQEAgc3RhdGljIHN0cnVjdCBpcF90dW5uZWwgKmlwX3R1bm5lbF9j
cmVhdGUoc3RydWN0IG5ldCAqbmV0LAogfQogCiBpbnQgaXBfdHVubmVsX3JjdihzdHJ1Y3QgaXBf
dHVubmVsICp0dW5uZWwsIHN0cnVjdCBza19idWZmICpza2IsCi0JCSAgY29uc3Qgc3RydWN0IHRu
bF9wdGtfaW5mbyAqdHBpLCBib29sIGxvZ19lY25fZXJyb3IpCisJCSAgY29uc3Qgc3RydWN0IHRu
bF9wdGtfaW5mbyAqdHBpLCBpbnQgaGRyX2xlbiwgYm9vbCBsb2dfZWNuX2Vycm9yKQogewogCXN0
cnVjdCBwY3B1X3RzdGF0cyAqdHN0YXRzOwogCWNvbnN0IHN0cnVjdCBpcGhkciAqaXBoID0gaXBf
aGRyKHNrYik7CkBAIC00MTMsNyArNDEzLDcgQEAgaW50IGlwX3R1bm5lbF9yY3Yoc3RydWN0IGlw
X3R1bm5lbCAqdHVubmVsLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCXNrYi0+cHJvdG9jb2wgPSB0
cGktPnByb3RvOwogCiAJc2tiLT5tYWNfaGVhZGVyID0gc2tiLT5uZXR3b3JrX2hlYWRlcjsKLQlf
X3Bza2JfcHVsbChza2IsIHR1bm5lbC0+aGxlbik7CisJX19wc2tiX3B1bGwoc2tiLCBoZHJfbGVu
KTsKIAlza2JfcG9zdHB1bGxfcmNzdW0oc2tiLCBza2JfdHJhbnNwb3J0X2hlYWRlcihza2IpLCB0
dW5uZWwtPmhsZW4pOwogI2lmZGVmIENPTkZJR19ORVRfSVBHUkVfQlJPQURDQVNUCiAJaWYgKGlw
djRfaXNfbXVsdGljYXN0KGlwaC0+ZGFkZHIpKSB7CmRpZmYgLS1naXQgYS9uZXQvaXB2NC9pcGlw
LmMgYi9uZXQvaXB2NC9pcGlwLmMKaW5kZXggN2NmYzQ1Ni4uZjVjYzdiMyAxMDA2NDQKLS0tIGEv
bmV0L2lwdjQvaXBpcC5jCisrKyBiL25ldC9pcHY0L2lwaXAuYwpAQCAtMTk1LDcgKzE5NSw3IEBA
IHN0YXRpYyBpbnQgaXBpcF9yY3Yoc3RydWN0IHNrX2J1ZmYgKnNrYikKIAlpZiAodHVubmVsKSB7
CiAJCWlmICgheGZybTRfcG9saWN5X2NoZWNrKE5VTEwsIFhGUk1fUE9MSUNZX0lOLCBza2IpKQog
CQkJZ290byBkcm9wOwotCQlyZXR1cm4gaXBfdHVubmVsX3Jjdih0dW5uZWwsIHNrYiwgJnRwaSwg
bG9nX2Vjbl9lcnJvcik7CisJCXJldHVybiBpcF90dW5uZWxfcmN2KHR1bm5lbCwgc2tiLCAmdHBp
LCAwLCBsb2dfZWNuX2Vycm9yKTsKIAl9CiAKIAlyZXR1cm4gLTE7Ci0tIAoxLjcuMQoK
--047d7b6dc224fb083c04e9925df5--
