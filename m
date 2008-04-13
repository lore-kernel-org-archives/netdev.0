From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Sun, 13 Apr 2008 22:18:54 +0200
Message-ID: <48026AAE.8040500@trash.net>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net> <480267C0.6020402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070408080903060201090903"
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756242AbYDMUWi@vger.kernel.org>
In-Reply-To: <480267C0.6020402@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070408080903060201090903
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>>>
>>> Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=10323
>>> Subject        : panic using bridging on linus kernel 2.6.25-rc6
>>> Submitter    : Andy Gospodarek <andy@greyhouse.net>
>>> Date        : 2008-03-25 11:40 (20 days old)
>>
>> This looks like another network-namespace regression.
>> icmp_send() does:
>>
>>        net = rt->u.dst.dev->nd_net;
>>
>> The bridge netfilter code attaches a fake dst_entry to the
>> skb which has dev == NULL when passing it to IPv4 netfilter.
>>
>> Pavel, do you have a better ideas for fixing this than
>> instantiating a dst_entry in br_netfilter.c for every
>> device (or at least for every namespace)? 
>
> The description of the problem was not entirely correct, the
> bridge-netfilter dst_entry does have a proper device pointer,
> it points to a dummy net_device structure however that doesn't
> have a namespace associated with it. This blows up in
> __ip_route_output_key.

For now I suggest this fix. Andy, could you please test whether it
fixes the problem?



--------------070408080903060201090903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

W0JSSURHRV06IEZpeCBjcmFzaCBpbiBfX2lwX3JvdXRlX291dHB1dF9rZXkgd2l0aCBicmlk
Z2UgbmV0ZmlsdGVyCgpUaGUgYnJpZGdlIG5ldGZpbHRlciBjb2RlIGF0dGFjaGVzIGEgZmFr
ZSBkc3RfZW50cnkgd2l0aCBhIHBvaW50ZXIgdG8gYQpmYWtlIG5ldF9kZXZpY2Ugc3RydWN0
dXJlIHRvIHNrYnMgaXQgcGFzc2VzIHVwIHRvIElQdjQgbmV0ZmlsdGVyLiBUaGlzCmxlYWRz
IHRvIGNyYXNoZXMgd2hlbiB0aGUgc2tiIGlzIHBhc3NlZCB0byBfX2lwX3JvdXRlX291dHB1
dF9rZXkgd2hlbgpkZXJlZmVyZW5jaW5nIHRoZSBuYW1lc3BhY2UgcG9pbnRlci4KClNpbmNl
IGJyaWRnaW5nIGNhbiBjdXJyZW50bHkgb25seSBvcGVyYXRlIGluIHRoZSBpbml0X25ldCBu
YW1lc3BhY2UsCnRoZSBlYXNpZXN0IGZpeCBmb3Igbm93IGlzIHRvIGluaXRpYWxpemUgdGhl
IG5kX25ldCBwb2ludGVyIG9mIHRoZQpmYWtlIG5ldF9kZXZpY2Ugc3RydWN0IHRvICZpbml0
X25ldC4KClNob3VsZCBmaXggYnVnemlsbGEgMTAzMjM6IGh0dHA6Ly9idWd6aWxsYS5rZXJu
ZWwub3JnL3Nob3dfYnVnLmNnaT9pZD0xMDMyMwoKU2lnbmVkLW9mZi1ieTogUGF0cmljayBN
Y0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+CgpkaWZmIC0tZ2l0IGEvbmV0L2JyaWRnZS9icl9u
ZXRmaWx0ZXIuYyBiL25ldC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmMKaW5kZXggMWMwZWZkOC4u
YWY3ZThiZSAxMDA2NDQKLS0tIGEvbmV0L2JyaWRnZS9icl9uZXRmaWx0ZXIuYworKysgYi9u
ZXQvYnJpZGdlL2JyX25ldGZpbHRlci5jCkBAIC0xMTAsNyArMTEwLDggQEAgc3RhdGljIGlu
bGluZSBfX2JlMTYgcHBwb2VfcHJvdG8oY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYikKICAq
IGlwdF9SRUpFQ1QgbmVlZHMgaXQuICBGdXR1cmUgbmV0ZmlsdGVyIG1vZHVsZXMgbWlnaHQK
ICAqIHJlcXVpcmUgdXMgdG8gZmlsbCBhZGRpdGlvbmFsIGZpZWxkcy4gKi8KIHN0YXRpYyBz
dHJ1Y3QgbmV0X2RldmljZSBfX2Zha2VfbmV0X2RldmljZSA9IHsKLQkuaGFyZF9oZWFkZXJf
bGVuCT0gRVRIX0hMRU4KKwkuaGFyZF9oZWFkZXJfbGVuCT0gRVRIX0hMRU4sCisJLm5kX25l
dAkJCT0gJmluaXRfbmV0LAogfTsKIAogc3RhdGljIHN0cnVjdCBydGFibGUgX19mYWtlX3J0
YWJsZSA9IHsK
--------------070408080903060201090903--
